part of 'katm_skip_bloc.dart';

final class KatmSkipState extends Equatable {
  const KatmSkipState({
    required this.contractId,
    required this.mibFailReason,
    required this.katmFailReason,
    required this.reasons,
    required this.form,
    required this.issue,
    required this.isLoading,
    required this.isLoaded,
    required this.isSending,
    required this.isDone,
    this.failure,
  });

  const KatmSkipState.initial({
    required this.contractId,
    required this.mibFailReason,
    required this.katmFailReason,
  }) : reasons = const <SkipReason>[],
       form = const KatmSkipForm(),
       issue = KatmSkipIssue.none,
       isLoading = false,
       isLoaded = false,
       isSending = false,
       isDone = false,
       failure = null;

  final int contractId;

  /// Nega bu ekran ochilgani — serverdan kelgan rad etish sabablari.
  final String mibFailReason;
  final String katmFailReason;

  final List<SkipReason> reasons;
  final KatmSkipForm form;
  final KatmSkipIssue issue;
  final bool isLoading;
  final bool isLoaded;
  final bool isSending;
  final bool isDone;
  final Failure? failure;

  bool get hasFailReasons => mibFailReason.isNotEmpty || katmFailReason.isNotEmpty;

  KatmSkipState copyWith({
    List<SkipReason>? reasons,
    KatmSkipForm? form,
    KatmSkipIssue? issue,
    bool? isLoading,
    bool? isLoaded,
    bool? isSending,
    bool? isDone,
    Failure? failure,
    bool clearFailure = false,
  }) => KatmSkipState(
    contractId: contractId,
    mibFailReason: mibFailReason,
    katmFailReason: katmFailReason,
    reasons: reasons ?? this.reasons,
    form: form ?? this.form,
    issue: issue ?? this.issue,
    isLoading: isLoading ?? this.isLoading,
    isLoaded: isLoaded ?? this.isLoaded,
    isSending: isSending ?? this.isSending,
    isDone: isDone ?? this.isDone,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    contractId,
    mibFailReason,
    katmFailReason,
    reasons,
    form,
    issue,
    isLoading,
    isLoaded,
    isSending,
    isDone,
    failure,
  ];
}
