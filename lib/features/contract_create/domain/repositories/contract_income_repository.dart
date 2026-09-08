import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';

/// Daromad bloki: qo'shimcha daromad turlari va plastik karta.
abstract interface class ContractIncomeRepository {
  /// Kasb turlari ro'yxati va ularning talab qilinishi.
  Future<Result<OccupationCatalog>> getOccupations();

  /// Kartani biriktiradi va uning id sini qaytaradi.
  Future<Result<int>> addCard(AddCardParams params);

  Future<Result<void>> removeCard(RemoveCardParams params);
}
