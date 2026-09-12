import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/signing_usecases.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { file, face, signature }

/// Shartnomani imzolash.
///
/// Ishtirokchilar orasida navbat yo'q: har biri o'z yuzini tasdiqlaydi va o'zi
/// imzolaydi. Shuning uchun natija har doim **o'sha ishtirokchining o'ziga**
/// yoziladi — flex'da bu ikkita alohida tarmoq edi (mijoz va kafil), va har
/// bir yangi maydon ikki joyda takrorlanardi.
final class ContractSigningBloc extends Bloc<ContractSigningEvent, ContractSigningState> {
  ContractSigningBloc({
    required ContractSigning signing,
    required this._getFile,
    required this._confirmFace,
    required this._sign,
    required this._changes,
    
  }) : super(ContractSigningState.initial(signing)) {
    on<ContractFileRequested>(_fileRequested, transformer: droppable());
    on<ContractRead>(_read);
    on<ParticipantToggled>(_toggled);
    on<FaceCaptured>(_faceCaptured, transformer: droppable());
    on<SignatureSubmitted>(_signatureSubmitted, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetContractFileUsecase _getFile;
  final ConfirmParticipantFaceUsecase _confirmFace;
  final SignContractUsecase _sign;

  /// Imzo qo'yilgach ro'yxatdagi holat eskiradi.
  final ContractChanges _changes;

  _Attempt _attempt = _Attempt.file;

  /// Yiqilgan amalni takrorlash uchun eslab qolinadi.
  FaceCaptured? _lastFace;
  SignatureSubmitted? _lastSignature;

  Future<void> _fileRequested(ContractFileRequested event, Emitter<ContractSigningState> emit) async {
    emit(state.copyWith(isFileLoading: true, clearFailure: true));

    final Result<String> result = await _getFile(
      ContractFileParams(contractId: state.signing.contractId, isFlex: state.signing.isFlex),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final String value): emit(state.copyWith(isFileLoading: false, contractFile: value));
      case Err(: final Failure failure):
        _attempt = _Attempt.file;
        emit(state.copyWith(isFileLoading: false, failure: failure));
    }
  }

  void _read(ContractRead event, Emitter<ContractSigningState> emit) => emit(state.copyWith(isRead: true));

  void _toggled(ParticipantToggled event, Emitter<ContractSigningState> emit) => emit(state.copyWith(expandedId: state.expandedId == event.participantId ? 0 : event.participantId));

  /// Yuz tasdig'i. Natija faqat `Ok` dan keyin mahalliy holatga yoziladi.
  Future<void> _faceCaptured(FaceCaptured event, Emitter<ContractSigningState> emit) async {
    final SigningParticipant? participant = state.signing.participantOf(event.participantId);
    if (participant == null || state.isBusy) return;

    _lastFace = event;
    emit(state.copyWith(write: SigningWrite.face, busyParticipantId: participant.id, clearFailure: true));

    final Result<void> result = await _confirmFace(
      FaceConfirmParams(contractId: state.signing.contractId, participant: participant, photo: event.photo),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        _changes.mark(ContractChange.updated);
        emit(state.copyWith(signing: state.signing.withParticipant(participant.copyWith(isFaceChecked: true)),write: SigningWrite.none,busyParticipantId: 0),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.face;
        emit(state.copyWith(write: SigningWrite.none, busyParticipantId: 0, failure: failure));
    }
  }

  Future<void> _signatureSubmitted(SignatureSubmitted event, Emitter<ContractSigningState> emit) async {
    final SigningParticipant? participant = state.signing.participantOf(event.participantId);
    if (participant == null || state.isBusy) return;

    _lastSignature = event;
    emit(state.copyWith(write: SigningWrite.signature, busyParticipantId: participant.id, clearFailure: true));

    final Result<SignatureResult> result = await _sign(SignatureParams(contractId: state.signing.contractId,participant: participant,signature: event.signature,comment: event.comment));
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final SignatureResult value): _changes.mark(ContractChange.updated);

        final ContractSigning signed = state.signing.withParticipant(participant.copyWith(signUrl: value.signUrl));

        // Server 201 bilan yakunlanganini aytishi mumkin, lekin bu tasdiqlangan
        // emas (backendga savol) — shuning uchun o'zimiz ham hisoblaymiz.
        emit(state.copyWith(signing: signed,write: SigningWrite.none,busyParticipantId: 0,isFinished: value.isContractSigned || signed.isAllSigned),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.signature;
        emit(state.copyWith(write: SigningWrite.none, busyParticipantId: 0, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<ContractSigningState> emit) => emit(state.copyWith(clearFailure: true));

  /// Aynan yiqilgan amalni takrorlaydi.
  ///
  /// Nega amal bo'yicha: bitta «Qayta urinish» hamma narsani qaytadan qilsa,
  /// imzo yiqilgandan keyin u shartnoma matnini qayta o'qib, foydalanuvchi
  /// so'ramagan yozuvni yuborardi.
  void _retried(Retried event, Emitter<ContractSigningState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.file: add(const ContractFileRequested());
      case _Attempt.face:
        final FaceCaptured? last = _lastFace;
        if (last != null) add(last);
      case _Attempt.signature:
        final SignatureSubmitted? last = _lastSignature;
        if (last != null) add(last);
    }
  }
}
