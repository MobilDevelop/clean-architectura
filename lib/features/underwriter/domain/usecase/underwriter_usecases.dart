import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/domain/repositories/underwriter_repository.dart';

final class LoadUnderwriterUsecase implements UseCase<UnderwriterData, int> {
  const LoadUnderwriterUsecase(this._repository);

  final UnderwriterRepository _repository;

  @override
  Future<Result<UnderwriterData>> call(int params) => _repository.load(params);
}

/// Ekran uchun kerak bo'lgan barcha ma'lumotnomalarni yig'adi.
///
/// Uch chaqiruvni ketma-ket bajarish — biznes qoidasi, shuning uchun u
/// bloc'da emas, shu yerda turadi (3.8). Ochilmaydigan bo'lim uchun so'rov
/// yuborilmaydi.
final class LoadReferencesUsecase implements UseCase<UnderwriterReferences, ReferencesQuery> {
  const LoadReferencesUsecase(this._repository);

  final UnderwriterRepository _repository;

  @override
  Future<Result<UnderwriterReferences>> call(ReferencesQuery params) async {
    List<MilitaryPosition> positions = const <MilitaryPosition>[];

    if (params.needsPositions) {
      final Result<List<MilitaryPosition>> result = await _repository.getPositions();

      switch (result) {
        case Ok(: final List<MilitaryPosition> value):
          positions = value;
        case Err(: final failure):
          return Err<UnderwriterReferences>(failure);
      }
    }

    final Result<List<UnderwriterOption>> brands = await _repository.getCarBrands();
    final List<UnderwriterOption> brandList;

    switch (brands) {
      case Ok(: final List<UnderwriterOption> value):
        brandList = value;
      case Err(: final failure):
        return Err<UnderwriterReferences>(failure);
    }

    if (params.brandId == 0) {
      return Ok<UnderwriterReferences>(
        UnderwriterReferences(positions: positions, brands: brandList, models: const <UnderwriterOption>[]),
      );
    }

    final Result<List<UnderwriterOption>> models = await _repository.getCarModels(params.brandId);

    return switch (models) {
      Ok(: final List<UnderwriterOption> value) => Ok<UnderwriterReferences>(
        UnderwriterReferences(positions: positions, brands: brandList, models: value),
      ),
      Err(: final failure) => Err<UnderwriterReferences>(failure),
    };
  }
}

final class GetCarModelsUsecase implements UseCase<List<UnderwriterOption>, int> {
  const GetCarModelsUsecase(this._repository);

  final UnderwriterRepository _repository;

  @override
  Future<Result<List<UnderwriterOption>>> call(int params) => _repository.getCarModels(params);
}

final class UploadDocumentUsecase implements UseCase<String, File> {
  const UploadDocumentUsecase(this._repository);

  final UnderwriterRepository _repository;

  @override
  Future<Result<String>> call(File params) => _repository.uploadFile(params);
}

/// Bo'limni saqlaydi.
///
/// Saqlashdan keyin `editId` yangilanishi kerak, aks holda ikkinchi bosishda
/// yana `POST` ketadi va serverda ikkinchi yozuv paydo bo'ladi. Server javobda
/// id qaytarmagani uchun yagona ishonchli yo'l — qayta o'qish.
///
/// Qayta o'qish yiqilsa natija baribir `Ok` bo'ladi, faqat `data` siz: yozuv
/// serverda allaqachon bor va uni takrorlash ikkinchi yozuv yaratadi.
final class SaveUnderwriterUsecase implements UseCase<SaveOutcome, SaveUnderwriterParams> {
  const SaveUnderwriterUsecase(this._repository);

  final UnderwriterRepository _repository;

  @override
  Future<Result<SaveOutcome>> call(SaveUnderwriterParams params) async {
    final Result<void> saved = await _repository.save(params);

    if (saved is Err<void>) return Err<SaveOutcome>(saved.failure);

    final Result<UnderwriterData> reloaded = await _repository.load(params.args.contractId);

    return switch (reloaded) {
      Ok(: final UnderwriterData value) => Ok<SaveOutcome>(
        SaveOutcome(data: value, reloadFailure: null),
      ),
      Err(: final Failure failure) => Ok<SaveOutcome>(
        SaveOutcome(data: null, reloadFailure: failure),
      ),
    };
  }
}
