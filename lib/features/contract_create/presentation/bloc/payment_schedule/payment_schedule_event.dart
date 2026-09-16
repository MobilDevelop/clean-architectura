part of 'payment_schedule_bloc.dart';

sealed class PaymentScheduleEvent extends Equatable {
  const PaymentScheduleEvent();

  @override
  List<Object?> get props => [];
}

final class ScheduleRequested extends PaymentScheduleEvent {
  const ScheduleRequested();
}

/// Jadvalni PDF qilib ulashish bosildi.
final class ScheduleShareRequested extends PaymentScheduleEvent {
  const ScheduleShareRequested();
}

/// Ulashish oynasi ochildi — fayl holatdan olib tashlanadi, aks holda ekran
/// qayta qurilganda oyna ikkinchi marta ochilardi.
final class ScheduleFileShared extends PaymentScheduleEvent {
  const ScheduleFileShared();
}

final class FailureHandled extends PaymentScheduleEvent {
  const FailureHandled();
}
