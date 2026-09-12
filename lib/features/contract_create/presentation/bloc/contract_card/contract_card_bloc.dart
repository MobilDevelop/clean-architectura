import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_card_event.dart';
part 'contract_card_state.dart';

/// Karta aylanmasi — shartnomaning alohida resursi.
///
/// Daromad asosi va avtomobil bayrog'i bu yerda emas: ular shartnoma
/// yozuvining bir qismi va faqat yuborishda saqlanadi. Karta esa darhol
/// serverga yoziladi, shuning uchun o'z bloci bor.
final class ContractCardBloc extends Bloc<ContractCardEvent, ContractCardState>
    with ContractWriteMixin<ContractCardEvent, ContractCardState> {
  ContractCardBloc({
    required int contractId,
    required int clientId,
    required ContractCard card,
    required this._addCard,
    required this._removeCard,
  }) : super(ContractCardState.initial(contractId: contractId, clientId: clientId, card: card)) {
    on<CardFieldChanged>(_fieldChanged);
    on<CardSubmitted>(_submitted, transformer: sequential());
    on<CardRemoved>(_removed, transformer: sequential());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final AddCardUsecase _addCard;
  final RemoveCardUsecase _removeCard;

  void _fieldChanged(CardFieldChanged event, Emitter<ContractCardState> emit) => emit(
    state.copyWith(
      form: state.form.copyWith(phone: event.phone, number: event.number, expiry: event.expiry),
      issue: CardFieldIssue.none,
    ),
  );

  Future<void> _submitted(CardSubmitted event, Emitter<ContractCardState> emit) async {
    final CardFieldIssue issue = state.form.issue;

    if (issue != CardFieldIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    await write<int>(
      event: event,
      emit: emit,
      busy: state.copyWith(write: CardWrite.adding, clearFailure: true),
      run: () => _addCard(AddCardParams(contractId: state.contractId, clientId: state.clientId, form: state.form)),
      // Karta faqat server id bergandan keyin ko'rinadi.
      onOk: (int id) => state.copyWith(
        write: CardWrite.none,
        revision: state.revision + 1,
        form: const CardForm(),
        card: ContractCard(
          id: id,
          number: state.form.number,
          phone: state.form.phone,
          month: state.form.month,
          year: state.form.year,
        ),
      ),
      onFailure: (Failure failure) => state.copyWith(write: CardWrite.none, failure: failure),
    );
  }

  Future<void> _removed(CardRemoved event, Emitter<ContractCardState> emit) async {
    if (state.card.isEmpty) return;

    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(write: CardWrite.removing, clearFailure: true),
      run: () => _removeCard(RemoveCardParams(cardId: state.card.id, contractId: state.contractId)),
      onOk: (_) => state.copyWith(
        write: CardWrite.none,
        revision: state.revision + 1,
        card: const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
      ),
      onFailure: (Failure failure) => state.copyWith(write: CardWrite.none, failure: failure),
    );
  }

  void _failureHandled(FailureHandled event, Emitter<ContractCardState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _retried(Retried event, Emitter<ContractCardState> emit) async {
    emit(state.copyWith(clearFailure: true));
    retryLastWrite();
  }
}
