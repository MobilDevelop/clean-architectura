import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';

abstract interface class ManagerBonusRepository {
  Future<Result<void>> sendDecision(SendBonusParams params);
}
