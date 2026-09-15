import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';
import 'package:colloborator_v3/features/change_password/domain/usecase/change_password_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

/// Parolni almashtirish. Muvaffaqiyatdan keyin sessiya tugatiladi — eski
/// token bilan ishlashda davom etish o'rniga xodim yangi parol bilan qayta
/// kirishi kerak (5.8: natija jimgina "ishladi" deb qolmaydi).
final class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({required this._changePassword, required this._auth}) : super(const ChangePasswordState.initial()) {
    on<ChangePasswordSubmitted>(_submitted, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final ChangePasswordUsecase _changePassword;
  final AuthNotifier _auth;

  ChangePasswordParams? _lastParams;

  Future<void> _submitted(ChangePasswordSubmitted event, Emitter<ChangePasswordState> emit) async {
    final PasswordFieldIssue issue = _issueOf(event.password, event.confirmation);
    if (issue != PasswordFieldIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    final ChangePasswordParams params = ChangePasswordParams(password: event.password);
    _lastParams = params;
    emit(state.copyWith(isSubmitting: true, issue: PasswordFieldIssue.none, clearFailure: true));

    final Result<void> result = await _changePassword(params);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isSubmitting: false));
        unawaited(_auth.signOut());
      case Err(: final Failure failure):
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<ChangePasswordState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<ChangePasswordState> emit) {
    emit(state.copyWith(clearFailure: true));

    final ChangePasswordParams? params = _lastParams;
    if (params != null) {
      add(ChangePasswordSubmitted(password: params.password, confirmation: params.password));
    }
  }

  PasswordFieldIssue _issueOf(String password, String confirmation) {
    if (password.length < PasswordRule.minLength) return PasswordFieldIssue.tooShort;
    if (password != confirmation) return PasswordFieldIssue.mismatch;

    return PasswordFieldIssue.none;
  }
}
