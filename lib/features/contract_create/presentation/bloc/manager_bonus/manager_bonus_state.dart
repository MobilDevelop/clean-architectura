part of 'manager_bonus_bloc.dart';

final class ManagerBonusState extends Equatable {
  const ManagerBonusState({
    required this.benefit,
    required this.form,
    required this.issue,
    required this.isSending,
    required this.isSent,
    this.failure,
  });

  const ManagerBonusState.initial(this.benefit)
    : form = const BonusForm(decision: BonusDecision.approved),
      issue = BonusIssue.none,
      isSending = false,
      isSent = false,
      failure = null;

  final ContractBenefit benefit;
  final BonusForm form;
  final BonusIssue issue;
  final bool isSending;
  final bool isSent;
  final Failure? failure;

  ManagerBonusState copyWith({
    BonusForm? form,
    BonusIssue? issue,
    bool? isSending,
    bool? isSent,
    Failure? failure,
    bool clearFailure = false,
  }) => ManagerBonusState(
    benefit: benefit,
    form: form ?? this.form,
    issue: issue ?? this.issue,
    isSending: isSending ?? this.isSending,
    isSent: isSent ?? this.isSent,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[benefit, form, issue, isSending, isSent, failure];
}
