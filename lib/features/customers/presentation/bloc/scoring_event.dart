part of 'scoring_bloc.dart';

sealed class ScoringEvent extends Equatable {
  const ScoringEvent();

  @override
  List<Object> get props => [];
}

final class ScoringFailureHandled extends ScoringEvent {
  const ScoringFailureHandled();
}

final class ScoringRequested extends ScoringEvent {
  const ScoringRequested(this.customerId);

  final int customerId;

  @override
  List<Object> get props => [customerId];
}
