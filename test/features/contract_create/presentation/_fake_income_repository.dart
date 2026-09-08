import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_income_repository.dart';

final class FakeContractIncomeRepository implements ContractIncomeRepository {
  Result<OccupationCatalog> catalogResult = const Ok<OccupationCatalog>(OccupationCatalog.empty());
  Result<int> addCardResult = const Ok<int>(7);
  Result<void> removeCardResult = const Ok<void>(null);

  int addCardCalls = 0;
  int removeCardCalls = 0;
  AddCardParams? lastCard;

  @override
  Future<Result<OccupationCatalog>> getOccupations() async => catalogResult;

  @override
  Future<Result<int>> addCard(AddCardParams params) async {
    addCardCalls++;
    lastCard = params;

    return addCardResult;
  }

  @override
  Future<Result<void>> removeCard(RemoveCardParams params) async {
    removeCardCalls++;

    return removeCardResult;
  }
}
