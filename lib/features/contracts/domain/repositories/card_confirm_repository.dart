import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';

abstract interface class CardConfirmRepository {
  Future<Result<CardConfirmation>> get(int contractId);

  Future<Result<void>> submit(CardConfirmParams params);
}
