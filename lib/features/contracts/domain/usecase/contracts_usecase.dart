import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class ContractsUsecase implements UseCase<List<ContractInfo>,ContractsFilter> {
  const ContractsUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<List<ContractInfo>>> call(ContractsFilter filter)=> _repository.getContracts(filter);
}