import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/guarantor_instruments_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'guarantor_instruments_event.dart';
part 'guarantor_instruments_state.dart';

final class InstrumentsBloc extends Bloc<InstrumentsEvent, InstrumentsState>
    with ContractWriteMixin<InstrumentsEvent, InstrumentsState> {
  InstrumentsBloc({required GuarantorRef ref, required this._load, required this._save})
    : super(InstrumentsState.initial(ref)) {
    on<InstrumentsStarted>(_started, transformer: restartable());
    on<InstrumentToggled>(_toggled);
    on<InstrumentCardChanged>(_cardChanged);
    on<InstrumentsSubmitted>(_submitted, transformer: sequential());
    on<InstrumentsFailureHandled>(_failureHandled);
    on<InstrumentsRetried>(_retried, transformer: droppable());
  }

  final LoadInstrumentsUsecase _load;
  final SaveInstrumentsUsecase _save;

  Future<void> _started(InstrumentsStarted event, Emitter<InstrumentsState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<GuarantorInstruments> result = await _load(state.ref);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final GuarantorInstruments value):
        emit(state.copyWith(isLoading: false, server: value, selected: value.types, card: const InstrumentCardDraft()));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Ziddiyat toast bilan emas, holat orqali aytiladi (6.2, 7.5).
  void _toggled(InstrumentToggled event, Emitter<InstrumentsState> emit) {
    final GuarantorInstruments? server = state.server;
    if (server == null) return;

    final Set<InstrumentType> next = Set<InstrumentType>.of(state.selected);

    if (next.remove(event.type)) {
      emit(state.copyWith(selected: next, issue: InstrumentIssue.none, clearConflict: true));
      return;
    }

    final InstrumentType? conflict = server.conflictOf(event.type, state.selected);

    if (conflict != null) {
      emit(state.copyWith(conflict: conflict));
      return;
    }

    next.add(event.type);
    emit(state.copyWith(selected: next, issue: InstrumentIssue.none, clearConflict: true));
  }

  void _cardChanged(InstrumentCardChanged event, Emitter<InstrumentsState> emit) => emit(
    state.copyWith(
      card: state.card.copyWith(number: event.number, expiry: event.expiry, phone: event.phone),
      issue: InstrumentIssue.none,
    ),
  );

  Future<void> _submitted(InstrumentsSubmitted event, Emitter<InstrumentsState> emit) async {
    final GuarantorInstruments? server = state.server;
    if (server == null) return;

    if (state.needsCard) {
      final InstrumentIssue issue = state.card.issueAt(DateTime.now());

      if (issue != InstrumentIssue.none) {
        emit(state.copyWith(issue: issue));
        return;
      }
    }

    await write<GuarantorInstruments>(
      event: event,
      emit: emit,
      busy: state.copyWith(isSaving: true, clearFailure: true),
      run: () => _save(
        SaveInstrumentsParams(
          contractId: state.ref.contractId,
          clientId: state.ref.clientId,
          types: state.selected,
          card: state.needsCard ? state.card : null,
          unknown: server.unknown,
        ),
      ),
      onOk: (GuarantorInstruments value) => state.copyWith(isSaving: false, isSaved: true, server: value),
      onFailure: (Failure failure) => state.copyWith(isSaving: false, failure: failure),
    );
  }

  void _failureHandled(InstrumentsFailureHandled event, Emitter<InstrumentsState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _retried(InstrumentsRetried event, Emitter<InstrumentsState> emit) async {
    emit(state.copyWith(clearFailure: true));

    // Xato yuklashda bo'lsa yozuv eslab qolinmagan — o'qishni qaytadan boshlaymiz.
    if (!retryLastWrite()) add(const InstrumentsStarted());
  }
}
