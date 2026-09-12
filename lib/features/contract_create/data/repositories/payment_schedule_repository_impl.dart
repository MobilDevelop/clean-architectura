import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/payment_schedule_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/schedule_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/payment_schedule_repository.dart';

final class PaymentScheduleRepositoryImpl implements PaymentScheduleRepository {
  const PaymentScheduleRepositoryImpl({required this._remote});

  final PaymentScheduleRemoteDatasource _remote;

  // DTO'dan entityga o'girish `guard` ICHIDA bajariladi: aks holda buzuq
  // javobda otilgan istisno repositorydan chiqib ketadi va bloc'ga yetadi
  // (5.5 — metod hech qachon otilmasligi kerak).
  @override
  Future<Result<PaymentSchedule>> getSchedule(ScheduleQuery query) => guard(() async {
    final List<ScheduleRowDto> rows = await _remote.getSchedule(query);

    return PaymentSchedule(rows.map((ScheduleRowDto dto) => dto.toEntity()).toList());
  });
}
