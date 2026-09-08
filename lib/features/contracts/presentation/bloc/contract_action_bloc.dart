import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_actions.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contract_authority_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_action_event.dart';
part 'contract_action_state.dart';

/// Amallar oynasining bloci.
///
/// Nega alohida: oyna ochilganda vakolat so'rovi ketadi va uning natijasi faqat
/// shu oynaga tegishli. Ro'yxat bloci bu bilan shug'ullanmasligi kerak.
final class ContractActionBloc extends Bloc<ContractActionEvent, ContractActionState> {
  ContractActionBloc({
    required ContractInfo contract,
    required this._getAuthority,
    required this._confirmAuthority,
    required this._escalateAuthority,
    required this._allowConfirmation,
    required this._cancelContract,
  }) : super(ContractActionState.initial(contract)) {
    on<ActionsRequested>(_actionsRequested);
    on<ApprovePressed>(_approvePressed);
    on<CancelConfirmed>(_cancelConfirmed);
    on<FailureHandled>(_failureHandled);
  }

  final GetAuthorityUsecase _getAuthority;
  final ConfirmAuthorityUsecase _confirmAuthority;
  final EscalateAuthorityUsecase _escalateAuthority;
  final AllowConfirmationUsecase _allowConfirmation;
  final CancelContractUsecase _cancelContract;

  /// Eski dvijokda ruxsat shartnomaning o'zidan hisoblanadi — so'rov ketmaydi.
  Future<void> _actionsRequested(ActionsRequested event, Emitter<ContractActionState> emit) async {
    if (state.contract.engine != AuthorityEngine.matrix) return;

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<ContractAuthority> result = await _getAuthority(state.contract.id);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final ContractAuthority value):
        emit(state.copyWith(isLoading: false, authority: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Tugma bitta, ma'nosi uchta. `proceed` so'rov yubormaydi — imzolash
  /// oqimiga o'tadi. Qolgan ikkisida so'rov dvijokka qarab tanlanadi: eski
  /// dvijokda ruxsat berish ham, yuborish ham bitta endpoint.
  Future<void> _approvePressed(ApprovePressed event, Emitter<ContractActionState> emit) async {
    final ContractActions actions = state.actions;

    if (actions.approve == ApproveAction.proceed) {
      emit(state.copyWith(isSigningRequested: true));
      return;
    }

    final bool isMatrix = state.contract.engine == AuthorityEngine.matrix;

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<void> result = switch ((isMatrix, actions.approve)) {
      (false, _) => await _allowConfirmation(state.contract.id),
      (true, ApproveAction.allow) => await _confirmAuthority(state.contract.id),
      (true, _) => await _escalateAuthority(state.contract.id),
    };
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isLoading: false, isDone: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _cancelConfirmed(CancelConfirmed event, Emitter<ContractActionState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<void> result = await _cancelContract(state.contract.id);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isLoading: false, isDone: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<ContractActionState> emit) =>
      emit(state.copyWith(clearFailure: true));
}
