part of 'manager_bonus_bloc.dart';

sealed class ManagerBonusEvent extends Equatable {
  const ManagerBonusEvent();

  @override
  List<Object?> get props => [];
}

final class BonusDecisionChanged extends ManagerBonusEvent {
  const BonusDecisionChanged(this.decision);

  final BonusDecision decision;

  @override
  List<Object?> get props => [decision];
}

final class BonusAmountChanged extends ManagerBonusEvent {
  const BonusAmountChanged(this.amount);

  final int amount;

  @override
  List<Object?> get props => [amount];
}

final class BonusCommentChanged extends ManagerBonusEvent {
  const BonusCommentChanged(this.comment);

  final String comment;

  @override
  List<Object?> get props => [comment];
}

final class BonusSubmitted extends ManagerBonusEvent {
  const BonusSubmitted();
}

final class FailureHandled extends ManagerBonusEvent {
  const FailureHandled();
}

final class Retried extends ManagerBonusEvent {
  const Retried();
}
