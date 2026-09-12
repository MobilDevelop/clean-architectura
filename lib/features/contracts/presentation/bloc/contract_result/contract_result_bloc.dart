import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_contract_scoring_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_flex_messages_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_katm_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_mib_usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/get_participants_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_result_event.dart';
part 'contract_result_state.dart';

final class ContractResultBloc extends Bloc<ContractResultEvent, ContractResultState> {
  ContractResultBloc({
    required this._contractId,
    required this._isFlex,
    required this._getScoring,
    required this._getFlexMessages,
    required this._getParticipants,
    required this._getMib,
    required this._getKatm,
  }) : super(const ContractResultState.initial()) {
    on<ScoringRequested>(_scoringRequested, transformer: droppable());

    // Tab ochilishi va ishtirokchi tanlash bitta navbatda ketadi: aks holda
    // ishtirokchilar hali kelmasdan KATM so'raladi va jimgina chiqib ketadi.
    on<MibOpened>(_mibOpened, transformer: sequential());
    on<KatmOpened>(_katmOpened, transformer: sequential());
    on<ParticipantSelected>(_participantSelected, transformer: sequential());
    on<MibRetried>(_mibRetried, transformer: sequential());
    on<KatmRetried>(_katmRetried, transformer: sequential());

    on<ScoringFailureHandled>(_scoringFailureHandled);
  }

  final int _contractId;

  /// Flex shartnomasida ro'yxat tepasida qo'shimcha xabarlar chiqadi.
  final bool _isFlex;

  final GetContractScoringUsecase _getScoring;
  final GetFlexMessagesUsecase _getFlexMessages;
  final GetParticipantsUsecase _getParticipants;
  final GetMibUsecase _getMib;
  final GetKatmUsecase _getKatm;

  Future<void> _scoringRequested(ScoringRequested event, Emitter<ContractResultState> emit) async {
    emit(state.copyWith(isScoringLoading: true, clearScoringFailure: true));

    final Result<List<ContractScoring>> result = await _getScoring(_contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<ContractScoring> value):
        emit(state.copyWith(isScoringLoading: false, isScoringLoaded: true, results: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isScoringLoading: false, scoringFailure: failure));
        return;
    }

    if (!_isFlex) return;

    // Xabarlar qo'shimcha ma'lumot: kelmasa ham skoring natijasi ko'rinaveradi.
    final Result<List<String>> messages = await _getFlexMessages(_contractId);
    if (emit.isDone) return;

    if (messages case Ok(: final List<String> value)) emit(state.copyWith(flexMessages: value));
  }

  Future<void> _mibOpened(MibOpened event, Emitter<ContractResultState> emit) => _ensureParticipants(emit);

  Future<void> _katmOpened(KatmOpened event, Emitter<ContractResultState> emit) async {
    emit(state.copyWith(isKatmOpened: true));

    await _ensureParticipants(emit);
    if (emit.isDone) return;

    final int? clientId = state.selectedClientId;
    if (clientId == null || state.katm != null) return;

    await _loadKatm(clientId, emit);
  }

  Future<void> _mibRetried(MibRetried event, Emitter<ContractResultState> emit) async {
    if (state.participants.isEmpty) {
      await _ensureParticipants(emit);
      return;
    }

    final int? clientId = state.selectedClientId;
    if (clientId != null) await _loadMib(clientId, emit);
  }

  Future<void> _katmRetried(KatmRetried event, Emitter<ContractResultState> emit) async {
    if (state.participants.isEmpty) {
      await _ensureParticipants(emit);
      if (emit.isDone) return;
    }

    final int? clientId = state.selectedClientId;
    if (clientId != null) await _loadKatm(clientId, emit);
  }

  Future<void> _participantSelected(ParticipantSelected event, Emitter<ContractResultState> emit) async {
    if (event.clientId == state.selectedClientId) return;

    // Eski hisobotlar yangi ishtirokchiga tegishli emas.
    emit(state.copyWith(selectedClientId: event.clientId, clearMib: true, clearKatm: true));

    await _loadMib(event.clientId, emit);
    if (emit.isDone) return;

    // KATM og'ir so'rov — faqat tab ochilgan bo'lsa qayta olinadi.
    if (state.isKatmOpened) await _loadKatm(event.clientId, emit);
  }

  /// Ro'yxat bir marta olinadi. Kelgach birinchi ishtirokchining MIB hisoboti
  /// darhol yuklanadi — aks holda tab bo'sh ochiladi.
  Future<void> _ensureParticipants(Emitter<ContractResultState> emit) async {
    if (state.participants.isNotEmpty) return;

    emit(state.copyWith(isParticipantsLoading: true, clearParticipantsFailure: true));

    final Result<List<CreditParticipant>> result = await _getParticipants(_contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<CreditParticipant> value):
        emit(state.copyWith(isParticipantsLoading: false, participants: value));
        if (value.isNotEmpty) {
          emit(state.copyWith(selectedClientId: value.first.clientId));
          await _loadMib(value.first.clientId, emit);
        }
      case Err(: final Failure failure):
        emit(state.copyWith(isParticipantsLoading: false, participantsFailure: failure));
    }
  }

  Future<void> _loadMib(int clientId, Emitter<ContractResultState> emit) async {
    emit(state.copyWith(isMibLoading: true, clearMib: true, clearMibFailure: true));

    final Result<MibReport> result = await _getMib(MibParams(contractId: _contractId, clientId: clientId));
    if (emit.isDone) return;

    // Kechikkan javob yangi tanlovni bosib ketmasligi kerak.
    if (state.selectedClientId != clientId) return;

    switch (result) {
      case Ok(: final MibReport value):
        emit(state.copyWith(isMibLoading: false, mib: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isMibLoading: false, mibFailure: failure));
    }
  }

  Future<void> _loadKatm(int clientId, Emitter<ContractResultState> emit) async {
    emit(state.copyWith(isKatmLoading: true, clearKatm: true, clearKatmFailure: true));

    final Result<KatmReport> result = await _getKatm(KatmParams(contractId: _contractId, clientId: clientId));
    if (emit.isDone) return;

    if (state.selectedClientId != clientId) return;

    switch (result) {
      case Ok(: final KatmReport value):
        emit(state.copyWith(isKatmLoading: false, katm: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isKatmLoading: false, katmFailure: failure));
    }
  }

  void _scoringFailureHandled(ScoringFailureHandled event, Emitter<ContractResultState> emit) =>
      emit(state.copyWith(clearScoringFailure: true));
}
