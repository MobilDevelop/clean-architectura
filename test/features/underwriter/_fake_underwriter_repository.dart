import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/domain/repositories/underwriter_repository.dart';

UnderwriterData emptyData({List<UnderwriterFile> salaryFiles = const <UnderwriterFile>[]}) =>
    UnderwriterData(
      salary: SalaryForm(editId: 0, files: salaryFiles, rows: const <SalaryRow>[]),
      pension: const PensionForm.empty(),
      student: const StudentForm.empty(),
      military: const MilitaryForm.empty(),
      car: const CarForm.empty(),
    );

/// Testlar uchun soxta anderrayter repositoryi.
final class FakeUnderwriterRepository implements UnderwriterRepository {
  Result<UnderwriterData> loadResult = Ok<UnderwriterData>(emptyData());
  Result<List<MilitaryPosition>> positionsResult = const Ok<List<MilitaryPosition>>(<MilitaryPosition>[]);
  Result<List<UnderwriterOption>> brandsResult = const Ok<List<UnderwriterOption>>(<UnderwriterOption>[]);
  Result<List<UnderwriterOption>> modelsResult = const Ok<List<UnderwriterOption>>(<UnderwriterOption>[]);
  Result<String> uploadResult = const Ok<String>('kalit');
  Result<void> saveResult = const Ok<void>(null);

  int loadCalls = 0;
  int brandCalls = 0;
  int uploadCalls = 0;
  int saveCalls = 0;

  @override
  Future<Result<UnderwriterData>> load(int contractId) async {
    loadCalls++;

    return loadResult;
  }

  @override
  Future<Result<List<MilitaryPosition>>> getPositions() async => positionsResult;

  @override
  Future<Result<List<UnderwriterOption>>> getCarBrands() async {
    brandCalls++;

    return brandsResult;
  }

  @override
  Future<Result<List<UnderwriterOption>>> getCarModels(int brandId) async => modelsResult;

  @override
  Future<Result<String>> uploadFile(File file) async {
    uploadCalls++;

    return uploadResult;
  }

  @override
  Future<Result<void>> save(SaveUnderwriterParams params) async {
    saveCalls++;

    return saveResult;
  }
}

const Failure network = NetworkFailure('aloqa yo`q');
