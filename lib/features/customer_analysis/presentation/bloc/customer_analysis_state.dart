part of 'customer_analysis_bloc.dart';

final class CustomerAnalysisState extends Equatable {
  const CustomerAnalysisState({
    required this.isLoading,
    required this.hasLoaded,
    required this.items,
    required this.isSubmitting,
    required this.issue,
    required this.submitted,
    required this.confirmingId,
    required this.confirmedId,
    this.failure,
  });

  const CustomerAnalysisState.initial()
    : isLoading = false,
      hasLoaded = false,
      items = const <CustomerAnalysis>[],
      isSubmitting = false,
      issue = AnalysisIssue.none,
      submitted = false,
      confirmingId = 0,
      confirmedId = 0,
      failure = null;

  final bool isLoading;

  /// Kamida bir marta javob kelgan — bo'sh ro'yxatni «hali so'ralmagan» dan
  /// ajratish uchun.
  final bool hasLoaded;

  final List<CustomerAnalysis> items;

  final bool isSubmitting;

  /// So'rov shaklidagi kamchilik — har bir maydon tagida ko'rsatiladi (7.5).
  final AnalysisIssue issue;

  /// So'rov muvaffaqiyatli yuborildi — bir martalik xabar uchun.
  final bool submitted;

  /// Hozir SMS kodi tasdiqlanayotgan yozuv. `0` — hech qaysi.
  final int confirmingId;

  /// Oxirgi tasdiqlangan yozuv — bir martalik xabar uchun.
  final int confirmedId;

  final Failure? failure;

  bool get isEmpty => hasLoaded && items.isEmpty;

  CustomerAnalysisState copyWith({
    bool? isLoading,
    bool? hasLoaded,
    List<CustomerAnalysis>? items,
    bool? isSubmitting,
    AnalysisIssue? issue,
    bool? submitted,
    int? confirmingId,
    int? confirmedId,
    Failure? failure,
    bool clearFailure = false,
  }) => CustomerAnalysisState(
    isLoading: isLoading ?? this.isLoading,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    items: items ?? this.items,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    issue: issue ?? this.issue,
    submitted: submitted ?? this.submitted,
    confirmingId: confirmingId ?? this.confirmingId,
    confirmedId: confirmedId ?? this.confirmedId,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    hasLoaded,
    items,
    isSubmitting,
    issue,
    submitted,
    confirmingId,
    confirmedId,
    failure,
  ];
}
