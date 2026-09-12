import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/icloud_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'credential_event.dart';
part 'credential_state.dart';

/// Bitta qurilmaning iCloud ma'lumotlari.
final class CredentialBloc extends Bloc<CredentialEvent, CredentialState> {
  CredentialBloc({
    required IcloudDevice device,
    required String clientName,
    required int contractId,
    required this._save,
  }) : super(CredentialState.initial(device: device, clientName: clientName, contractId: contractId)) {
    on<CredentialFieldChanged>(_fieldChanged);
    on<BoxSelected>(_boxSelected);
    on<AppleLoginSelected>(_appleLoginSelected);
    on<ApplePasswordSelected>(_applePasswordSelected);
    on<CredentialSubmitted>(_submitted, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final SaveIcloudCredentialUsecase _save;

  /// Har o'zgarishda xato yozuvi so'nadi: tuzatilgan maydon tagida qizil
  /// yozuv turib qolishi kerak emas.
  void _fieldChanged(CredentialFieldChanged event, Emitter<CredentialState> emit) {
    final IcloudCredential current = state.credential;
    final String value = event.value;

    final IcloudCredential next = switch (event.field) {
      CredentialField.condition => current.copyWith(condition: value),
      CredentialField.imei => current.copyWith(imei: value),
      CredentialField.imei2 => current.copyWith(imei2: value),
      CredentialField.serialNumber => current.copyWith(serialNumber: value),
      CredentialField.login => current.copyWith(login: value),
      CredentialField.password => current.copyWith(password: value),
      CredentialField.restrictionCode => current.copyWith(restrictionCode: value),
      CredentialField.phone => current.copyWith(phone: value),
    };

    emit(state.copyWith(credential: next, issue: IcloudIssue.none));
  }

  void _boxSelected(BoxSelected event, Emitter<CredentialState> emit) => emit(
    state.copyWith(credential: state.credential.copyWith(hasBox: event.hasBox), issue: IcloudIssue.none),
  );

  void _appleLoginSelected(AppleLoginSelected event, Emitter<CredentialState> emit) => emit(
    state.copyWith(credential: state.credential.copyWith(appleLogin: event.owner), issue: IcloudIssue.none),
  );

  void _applePasswordSelected(ApplePasswordSelected event, Emitter<CredentialState> emit) => emit(
    state.copyWith(
      credential: state.credential.copyWith(applePassword: event.owner),
      issue: IcloudIssue.none,
    ),
  );

  Future<void> _submitted(CredentialSubmitted event, Emitter<CredentialState> emit) async {
    final IcloudIssue issue = state.credential.issue;

    if (issue != IcloudIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    emit(state.copyWith(isSaving: true, issue: IcloudIssue.none, clearFailure: true));

    final Result<void> result = await _save(state.credential);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isSaving: false, isSaved: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isSaving: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<CredentialState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<CredentialState> emit) {
    emit(state.copyWith(clearFailure: true));
    add(const CredentialSubmitted());
  }
}
