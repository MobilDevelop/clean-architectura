import 'dart:io';

import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_file_repository.dart';

final class DownloadContractFileUsecase implements UseCase<File, String> {
  const DownloadContractFileUsecase(this._repository);

  final ContractFileRepository _repository;

  @override
  Future<Result<File>> call(String params) => _repository.download(params);
}
