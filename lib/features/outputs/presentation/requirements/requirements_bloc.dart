import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/icloud_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'requirements_event.dart';
part 'requirements_state.dart';

/// Chiqimdan oldin to'ldirilishi kerak bo'lgan qurilmalar ro'yxati.
final class RequirementsBloc extends Bloc<RequirementsEvent, RequirementsState> {
  RequirementsBloc({required int contractId, required this._getRequirements})
    : super(RequirementsState.initial(contractId)) {
    on<RequirementsRequested>(_requested, transformer: restartable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final GetIcloudRequirementsUsecase _getRequirements;

  Future<void> _requested(RequirementsRequested event, Emitter<RequirementsState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<IcloudRequirements> result = await _getRequirements(state.contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final IcloudRequirements value):
        emit(state.copyWith(isLoading: false, requirements: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<RequirementsState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<RequirementsState> emit) {
    emit(state.copyWith(clearFailure: true));
    add(const RequirementsRequested());
  }
}
