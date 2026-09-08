import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/manager_bonus_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'manager_bonus_event.dart';
part 'manager_bonus_state.dart';


/// Filial rahbari bonusi: tasdiqlash yoki rad etish.
///
/// Flex bu chaqiruvni yuklanish belgisisiz va xatosiz yuborardi — tugma
/// yo'qolardi, natija esa noma'lum qolardi.
final class ManagerBonusBloc extends Bloc<ManagerBonusEvent, ManagerBonusState>
    with ContractWriteMixin<ManagerBonusEvent, ManagerBonusState> {
  ManagerBonusBloc({required ContractBenefit benefit, required this._send})
    : super(ManagerBonusState.initial(benefit)) {
    on<BonusDecisionChanged>(_decisionChanged);
    on<BonusAmountChanged>(_amountChanged);
    on<BonusCommentChanged>(_commentChanged);
    on<BonusSubmitted>(_submitted, transformer: sequential());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final SendBonusUsecase _send;

  void _decisionChanged(BonusDecisionChanged event, Emitter<ManagerBonusState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(decision: event.decision), issue: BonusIssue.none));

  void _amountChanged(BonusAmountChanged event, Emitter<ManagerBonusState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(amount: event.amount), issue: BonusIssue.none));

  void _commentChanged(BonusCommentChanged event, Emitter<ManagerBonusState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(comment: event.comment), issue: BonusIssue.none));

  Future<void> _submitted(BonusSubmitted event, Emitter<ManagerBonusState> emit) async {
    final BonusIssue issue = state.form.issueAt(availableAmount: state.benefit.availableAmount);

    if (issue != BonusIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(isSending: true, clearFailure: true),
      run: () => _send(SendBonusParams(contractId: state.benefit.contractId, form: state.form)),
      onOk: (_) => state.copyWith(isSending: false, isSent: true),
      onFailure: (Failure failure) => state.copyWith(isSending: false, failure: failure),
    );
  }

  void _failureHandled(FailureHandled event, Emitter<ManagerBonusState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _retried(Retried event, Emitter<ManagerBonusState> emit) async {
    emit(state.copyWith(clearFailure: true));
    retryLastWrite();
  }
}
