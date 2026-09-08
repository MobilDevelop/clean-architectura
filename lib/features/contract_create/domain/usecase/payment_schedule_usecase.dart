import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/payment_schedule_repository.dart';

final class GetScheduleUsecase implements UseCase<PaymentSchedule, ScheduleQuery> {
  const GetScheduleUsecase(this._repository);

  final PaymentScheduleRepository _repository;

  @override
  Future<Result<PaymentSchedule>> call(ScheduleQuery params) => _repository.getSchedule(params);
}
