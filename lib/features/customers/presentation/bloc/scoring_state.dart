part of 'scoring_bloc.dart';

final class ScoringState extends Equatable {
  const ScoringState({required this.isLoading, this.info, this.failure});

  const ScoringState.initial() : isLoading = false, info = null, failure = null;

  final bool isLoading;
  final ScoringInfo? info;
  final Failure? failure;

  ScoringState copyWith({bool? isLoading, ScoringInfo? info, Failure? failure, bool clearFailure = false}) =>
      ScoringState(
        isLoading: isLoading ?? this.isLoading,
        info: info ?? this.info,
        failure: clearFailure ? null : failure ?? this.failure,
      );

  @override
  List<Object?> get props => [isLoading, info, failure];
}
