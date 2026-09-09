import 'dart:io';

import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/underwriter/data/datasources/underwriter_remote_datasource.dart';
import 'package:colloborator_v3/features/underwriter/data/models/underwriter_dto.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/domain/repositories/underwriter_repository.dart';

final class UnderwriterRepositoryImpl implements UnderwriterRepository {
  const UnderwriterRepositoryImpl({required this._remote});

  final UnderwriterRemoteDatasource _remote;

  @override
  Future<Result<UnderwriterData>> load(int contractId) => guard(() async {
    final UnderwriterDataDto? dto = await _remote.load(contractId);

    // `null` — server hali hech nima saqlanmaganini aytdi (`UnderwriterDataDto.tryFrom`).
    // Bu xato emas, lekin `id` lar nolda qolishi kerak: aks holda mavjud yozuv
    // ustidan ikkinchisi yaratilib ketardi.
    if (dto == null) return UnderwriterDataDto.fromJson(const <String, dynamic>{}).toEntity();

    return dto.toEntity();
  });

  @override
  Future<Result<List<MilitaryPosition>>> getPositions() => guard(() async {
    final List<MilitaryPositionDto> list = await _remote.getPositions();

    return list.map((MilitaryPositionDto dto) => dto.toEntity()).toList();
  });

  @override
  Future<Result<List<UnderwriterOption>>> getCarBrands() => guard(() async {
    final List<OptionDto> list = await _remote.getCarBrands();

    return list.map((OptionDto dto) => dto.toEntity()).toList();
  });

  @override
  Future<Result<List<UnderwriterOption>>> getCarModels(int brandId) => guard(() async {
    final List<OptionDto> list = await _remote.getCarModels(brandId);

    return list.map((OptionDto dto) => dto.toEntity()).toList();
  });

  /// Ikki qadam bitta amal sifatida.
  ///
  /// Kalit **faqat baytlar yozilgandan keyin** qaytariladi. Flex esa yozish
  /// natijasini tekshirmasdan kalitni saqlab qo'yardi — natijada serverda
  /// mavjud bo'lmagan faylga havola qolardi.
  @override
  Future<Result<String>> uploadFile(File file) => guard(() async {
    final List<int> bytes = await _remote.readBytes(file);
    final String extension = file.path.split('.').last.toLowerCase();

    final FileDirectionDto? direction = await _remote.requestUpload(
      extension: extension,
      length: bytes.length,
    );

    final String url = direction?.uploadUrl ?? '';
    final String key = direction?.fileKey ?? '';

    if (url.isEmpty || key.isEmpty) throw const FormatException('upload_url');

    await _remote.putToStorage(url: url, bytes: bytes, mime: UnderwriterFileRule.mimeOf(extension));

    return key;
  });

  @override
  Future<Result<void>> save(SaveUnderwriterParams params) => guard(() => _remote.save(params));
}
