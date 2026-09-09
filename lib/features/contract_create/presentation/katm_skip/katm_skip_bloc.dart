import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/katm_skip_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'katm_skip_event.dart';
part 'katm_skip_state.dart';

/// KATM/MIB tekshiruvini o'tkazib yuborish.
///
/// Server HTTP 200 bilan `success: false` qaytarishi mumkin — u repositoryda
/// `Err` ga aylantirilgan, shuning uchun bu yerda oddiy xato kabi ko'rinadi.
final class KatmSkipBloc extends Bloc<KatmSkipEvent, KatmSkipState>
    with ContractWriteMixin<KatmSkipEvent, KatmSkipState> {
  KatmSkipBloc({
    required int contractId,
    required String mibFailReason,
    required String katmFailReason,
    required this._getReasons,
    required this._turnOff,
  }) : super(
         KatmSkipState.initial(
           contractId: contractId,
           mibFailReason: mibFailReason,
           katmFailReason: katmFailReason,
         ),
       ) {
    on<ReasonsRequested>(_requested, transformer: droppable());
    on<ReasonSelected>(_reasonSelected);
    on<CommentChanged>(_commentChanged);
    on<SkipSubmitted>(_submitted, transformer: sequential());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetSkipReasonsUsecase _getReasons;
  final TurnOffKatmUsecase _turnOff;

  Future<void> _requested(ReasonsRequested event, Emitter<KatmSkipState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<List<SkipReason>> result = await _getReasons(const NoParams());
    if (emit.isDone) return;

    switch (result) {
      case Ok(:final List<SkipReason> value):
        emit(state.copyWith(isLoading: false, isLoaded: true, reasons: value));
      // Flex bu xatoni butunlay yutardi va foydalanuvchi bo'sh ro'yxat ko'rardi.
      case Err(:final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _reasonSelected(ReasonSelected event, Emitter<KatmSkipState> emit) => emit(
    state.copyWith(
      form: state.form.copyWith(reason: event.reason),
      issue: KatmSkipIssue.none,
    ),
  );

  void _commentChanged(CommentChanged event, Emitter<KatmSkipState> emit) => emit(
    state.copyWith(
      form: state.form.copyWith(comment: event.comment),
      issue: KatmSkipIssue.none,
    ),
  );

  Future<void> _submitted(SkipSubmitted event, Emitter<KatmSkipState> emit) async {
    final KatmSkipIssue issue = state.form.issue;

    if (issue != KatmSkipIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(isSending: true, clearFailure: true),
      run: () => _turnOff(KatmSkipParams(contractId: state.contractId, form: state.form)),
      onOk: (_) => state.copyWith(isSending: false, isDone: true),
      onFailure: (Failure failure) => state.copyWith(isSending: false, failure: failure),
    );
  }

  void _failureHandled(FailureHandled event, Emitter<KatmSkipState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _retried(Retried event, Emitter<KatmSkipState> emit) async {
    emit(state.copyWith(clearFailure: true));

    if (!retryLastWrite()) add(const ReasonsRequested());
  }
}
