import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_guarantor_repository.dart';

final class AddGuarantorUsecase implements UseCase<int, AddGuarantorParams> {
  const AddGuarantorUsecase(this._repository);

  final ContractGuarantorRepository _repository;

  @override
  Future<Result<int>> call(AddGuarantorParams params) => _repository.addGuarantor(params);
}

final class RemoveGuarantorUsecase implements UseCase<void, RemoveGuarantorParams> {
  const RemoveGuarantorUsecase(this._repository);

  final ContractGuarantorRepository _repository;

  @override
  Future<Result<void>> call(RemoveGuarantorParams params) => _repository.removeGuarantor(params);
}
