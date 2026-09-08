import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';

abstract interface class PaymentScheduleRepository {
  Future<Result<PaymentSchedule>> getSchedule(ScheduleQuery query);
}
