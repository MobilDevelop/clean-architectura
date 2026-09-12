part of 'payment_schedule_bloc.dart';

sealed class PaymentScheduleEvent extends Equatable {
  const PaymentScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleRequested extends PaymentScheduleEvent {
  const ScheduleRequested();
}

final class FailureHandled extends PaymentScheduleEvent {
  const FailureHandled();
}
