import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_scoring_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'scoring_event.dart';
part 'scoring_state.dart';

final class ScoringBloc extends Bloc<ScoringEvent, ScoringState> {
  ScoringBloc({required this._getScoring}) : super(const ScoringState.initial()) {
    on<ScoringRequested>(_requested);
    on<ScoringFailureHandled>(_failureHandled);
  }

  final GetScoringUsecase _getScoring;

  void _failureHandled(ScoringFailureHandled event, Emitter<ScoringState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _requested(ScoringRequested event, Emitter<ScoringState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<ScoringInfo> result = await _getScoring(event.customerId);

    switch (result) {
      case Ok(: final ScoringInfo value):
        emit(state.copyWith(isLoading: false, info: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }
}
