import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_guarantor_remote_datasource.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_guarantor_repository.dart';

final class ContractGuarantorRepositoryImpl implements ContractGuarantorRepository {
  const ContractGuarantorRepositoryImpl({required this._remote});

  final ContractGuarantorRemoteDatasource _remote;

  @override
  Future<Result<int>> addGuarantor(AddGuarantorParams params) async =>
      requireValue(await guard(() => _remote.addGuarantor(params)));

  @override
  Future<Result<void>> removeGuarantor(RemoveGuarantorParams params) =>
      guard(() => _remote.removeGuarantor(params));
}
