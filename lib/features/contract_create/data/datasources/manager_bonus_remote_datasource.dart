import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:dio/dio.dart';

final class ManagerBonusRemoteDatasource {
  const ManagerBonusRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<void> sendDecision(SendBonusParams params) => _dio.post<dynamic>(
    Endpoints.managerBonus,
    data: <String, dynamic>{
      'benefit_sum': params.form.amount,
      'status': params.form.decision.code,
      'comment': params.form.comment.trim(),
      'contract_id': params.contractId,
    },
  );
}
