import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/contract_create/data/models/schedule_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:dio/dio.dart';

final class PaymentScheduleRemoteDatasource {
  const PaymentScheduleRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Muddat va to'lov kuni so'rovda ketadi: ular hali qoralamaga saqlanmagan
  /// bo'lishi mumkin, server esa jadvalni aynan shulardan hisoblaydi.
  Future<List<ScheduleRowDto>> getSchedule(ScheduleQuery query) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.generateGraphic,
      queryParameters: <String, dynamic>{
        'term': query.termMonths,
        'payment_day': query.paymentDay,
        'contract_id': query.contractId,
        'is_unformal_contract': query.isInformal ? 1 : 0,
      },
    );

    final Object? rows = result.data?['graphics'];
    if (rows is! List) return const <ScheduleRowDto>[];

    return rows.whereType<Map<String, dynamic>>().map(ScheduleRowDto.fromJson).toList();
  }
}
