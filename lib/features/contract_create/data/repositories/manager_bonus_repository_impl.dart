import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/manager_bonus_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/result_guard.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/manager_bonus_repository.dart';

final class ManagerBonusRepositoryImpl implements ManagerBonusRepository {
  const ManagerBonusRepositoryImpl({required this._remote});

  final ManagerBonusRemoteDatasource _remote;

  @override
  Future<Result<void>> sendDecision(SendBonusParams params) => guard(() => _remote.sendDecision(params));
}
