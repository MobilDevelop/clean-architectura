part of 'katm_skip_bloc.dart';

sealed class KatmSkipEvent extends Equatable {
  const KatmSkipEvent();

  @override
  List<Object?> get props => [];
}

final class ReasonsRequested extends KatmSkipEvent {
  const ReasonsRequested();
}

final class ReasonSelected extends KatmSkipEvent {
  const ReasonSelected(this.reason);

  final SkipReason reason;

  @override
  List<Object?> get props => [reason];
}

final class CommentChanged extends KatmSkipEvent {
  const CommentChanged(this.comment);

  final String comment;

  @override
  List<Object?> get props => [comment];
}

final class SkipSubmitted extends KatmSkipEvent {
  const SkipSubmitted();
}

final class FailureHandled extends KatmSkipEvent {
  const FailureHandled();
}

final class Retried extends KatmSkipEvent {
  const Retried();
}
