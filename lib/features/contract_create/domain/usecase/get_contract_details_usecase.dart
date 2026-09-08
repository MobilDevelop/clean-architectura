import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';

final class GetContractDetailsUsecase implements UseCase<ContractDetails, int> {
  const GetContractDetailsUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<ContractDetails>> call(int params) => _repository.getDetails(params);
}
