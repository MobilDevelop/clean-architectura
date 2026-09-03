import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetContractScoringUsecase implements UseCase<List<ContractScoring>, int> {
  const GetContractScoringUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<List<ContractScoring>>> call(int params) => _repository.getScoring(params);
}
