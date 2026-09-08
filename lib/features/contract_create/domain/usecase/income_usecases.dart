import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_income_repository.dart';

final class GetOccupationsUsecase implements UseCase<OccupationCatalog, NoParams> {
  const GetOccupationsUsecase(this._repository);

  final ContractIncomeRepository _repository;

  @override
  Future<Result<OccupationCatalog>> call(NoParams params) => _repository.getOccupations();
}

final class AddCardUsecase implements UseCase<int, AddCardParams> {
  const AddCardUsecase(this._repository);

  final ContractIncomeRepository _repository;

  @override
  Future<Result<int>> call(AddCardParams params) => _repository.addCard(params);
}

final class RemoveCardUsecase implements UseCase<void, RemoveCardParams> {
  const RemoveCardUsecase(this._repository);

  final ContractIncomeRepository _repository;

  @override
  Future<Result<void>> call(RemoveCardParams params) => _repository.removeCard(params);
}
