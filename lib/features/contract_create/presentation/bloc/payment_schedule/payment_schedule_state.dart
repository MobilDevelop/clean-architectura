part of 'payment_schedule_bloc.dart';

// `dart:io` ni `payment_schedule_bloc.dart` import qiladi.

final class PaymentScheduleState extends Equatable {
  const PaymentScheduleState({
    required this.query,
    required this.schedule,
    required this.isLoading,
    required this.isLoaded,
    required this.isSharing,
    this.shareFile,
    this.failure,
  });

  const PaymentScheduleState.initial(this.query)
    : schedule = const PaymentSchedule(<ScheduleRow>[]),
      isLoading = false,
      isLoaded = false,
      isSharing = false,
      shareFile = null,
      failure = null;

  final ScheduleQuery query;
  final PaymentSchedule schedule;
  final bool isLoading;

  /// Javob kelgan. Bo'sh jadval bilan "hali so'ralmagan" ni ajratadi.
  final bool isLoaded;

  final bool isSharing;

  /// Tayyor PDF. `null` — hali yasalmagan yoki oyna allaqachon ochilgan.
  final File? shareFile;

  final Failure? failure;

  /// Bo'sh jadvalni ulashishdan ma'no yo'q.
  bool get canShare => isLoaded && !schedule.isEmpty;

  PaymentScheduleState copyWith({
    PaymentSchedule? schedule,
    bool? isLoading,
    bool? isLoaded,
    bool? isSharing,
    File? shareFile,
    bool clearShareFile = false,
    Failure? failure,
    bool clearFailure = false,
  }) => PaymentScheduleState(
    query: query,
    schedule: schedule ?? this.schedule,
    isLoading: isLoading ?? this.isLoading,
    isLoaded: isLoaded ?? this.isLoaded,
    isSharing: isSharing ?? this.isSharing,
    shareFile: clearShareFile ? null : shareFile ?? this.shareFile,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    query,
    schedule,
    isLoading,
    isLoaded,
    isSharing,
    shareFile?.path,
    failure,
  ];
}
