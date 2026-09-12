part of 'payment_schedule_bloc.dart';

final class PaymentScheduleState extends Equatable {
  const PaymentScheduleState({
    required this.query,
    required this.schedule,
    required this.isLoading,
    required this.isLoaded,
    this.failure,
  });

  const PaymentScheduleState.initial(this.query)
    : schedule = const PaymentSchedule(<ScheduleRow>[]),
      isLoading = false,
      isLoaded = false,
      failure = null;

  final ScheduleQuery query;
  final PaymentSchedule schedule;
  final bool isLoading;

  /// Javob kelgan. Bo'sh jadval bilan "hali so'ralmagan" ni ajratadi.
  final bool isLoaded;

  final Failure? failure;

  PaymentScheduleState copyWith({
    PaymentSchedule? schedule,
    bool? isLoading,
    bool? isLoaded,
    Failure? failure,
    bool clearFailure = false,
  }) => PaymentScheduleState(
    query: query,
    schedule: schedule ?? this.schedule,
    isLoading: isLoading ?? this.isLoading,
    isLoaded: isLoaded ?? this.isLoaded,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[query, schedule, isLoading, isLoaded, failure];
}
