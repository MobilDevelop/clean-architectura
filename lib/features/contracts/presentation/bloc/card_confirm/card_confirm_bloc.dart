import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/card_confirm_usecases.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { load, submit }

/// Shartnomaga qo'shilgan kartani tasdiqlash (ELMA OTP).
///
/// Bosqichni server aytadi: kod kutilmoqda, kod qayta yuborilishi kerak yoki
/// karta ma'lumoti to'ldirilishi kerak. Ekran bittasini ko'rsatadi, qaysi
/// birini — shu bloc hal qiladi.
final class CardConfirmBloc extends Bloc<CardConfirmEvent, CardConfirmState> {
  CardConfirmBloc({
    required int contractId,
    required this._get,
    required this._submit,
    required this._changes,
  }) : super(CardConfirmState.initial(contractId)) {
    on<CardConfirmRequested>(_requested, transformer: droppable());
    on<CodeChanged>(_codeChanged);
    on<SkipCardToggled>(_skipToggled);
    on<CardEntryChanged>(_entryChanged);
    on<CardConfirmSubmitted>(_submitted, transformer: droppable());
    on<CodeResendRequested>(_resendRequested, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetCardConfirmationUsecase _get;
  final SubmitCardConfirmationUsecase _submit;

  /// Tasdiqlangach shartnomaning ro'yxatdagi holati eskiradi.
  final ContractChanges _changes;

  _Attempt _attempt = _Attempt.load;
  CardConfirmAction? _lastAction;

  Future<void> _requested(CardConfirmRequested event, Emitter<CardConfirmState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<CardConfirmation> result = await _get(state.contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final CardConfirmation value):
        emit(state.copyWith(isLoading: false, data: value));
      case Err(: final Failure failure):
        _attempt = _Attempt.load;
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _codeChanged(CodeChanged event, Emitter<CardConfirmState> emit) => emit(state.copyWith(code: event.code));

  void _skipToggled(SkipCardToggled event, Emitter<CardConfirmState> emit) => emit(state.copyWith(isSkipCard: !state.isSkipCard));

  void _entryChanged(CardEntryChanged event, Emitter<CardConfirmState> emit) => emit(state.copyWith(entry: event.entry));

  Future<void> _submitted(CardConfirmSubmitted event, Emitter<CardConfirmState> emit) => _send(state.action, emit);

  Future<void> _resendRequested(CodeResendRequested event, Emitter<CardConfirmState> emit) => _send(CardConfirmAction.resend, emit);

  Future<void> _send(CardConfirmAction action, Emitter<CardConfirmState> emit) async {
    final CardConfirmation? data = state.data;
    if (data == null || state.isBusy) return;

    _lastAction = action;
    emit(state.copyWith(isSubmitting: true, clearFailure: true));

    final Result<void> result = await _submit(CardConfirmParams(confirmation: data, action: action, code: state.code, entry: state.entry));
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        _changes.mark(ContractChange.updated);
        emit(state.copyWith(isSubmitting: false, isDone: true));
      case Err(: final Failure failure):
        _attempt = _Attempt.submit;
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<CardConfirmState> emit) => emit(state.copyWith(clearFailure: true));

  /// Aynan yiqilgan amalni takrorlaydi.
  ///
  /// Nega amal bo'yicha: bitta «Qayta urinish» hamma narsani qaytadan qilsa,
  /// yiqilgan yuborishdan keyin u holatni qayta o'qib qo'yardi va xodim
  /// kodni ikkinchi marta kiritishga majbur bo'lardi.
  void _retried(Retried event, Emitter<CardConfirmState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.load:
        add(const CardConfirmRequested());
      case _Attempt.submit:
        final CardConfirmAction? last = _lastAction;
        if (last == null) return;

        add(last == CardConfirmAction.resend ? const CodeResendRequested() : const CardConfirmSubmitted());
    }
  }
}
