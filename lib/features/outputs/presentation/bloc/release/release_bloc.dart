import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/utils/camera_issue.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/icloud_usecases.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/release_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'release_event.dart';
part 'release_state.dart';

/// Qaysi amal yiqildi.
enum _Attempt { requirements, submit }

/// Chiqim berish: iCloud talablari tekshiruvi, tovarlar surati va SMS kod.
///
/// Talab tekshiruvi shu yerda, ro'yxat bloc'ida emas: u chiqimning birinchi
/// qadami, ro'yxatning ishi emas. Flex uni ro'yxat bloc'iga qo'ygani uchun
/// ro'yxat iCloud xizmatini ham bilishi kerak bo'lgan.
final class ReleaseBloc extends Bloc<ReleaseEvent, ReleaseState> {
  ReleaseBloc({
    required OutputContract contract,
    required this._getRequirements,
    required this._confirmRelease,
    required this._changes,
  }) : super(ReleaseState.initial(contract)) {
    on<ReleaseStarted>(_started, transformer: droppable());
    on<PhotoTaken>(_photoTaken);
    on<CameraRefused>(_cameraRefused);
    on<CodeChanged>(_codeChanged);
    // `droppable`: tasdiq qaytarib bo'lmaydigan amal — ikkinchi bosish
    // ikkinchi so'rov yubormaydi.
    on<ReleaseSubmitted>(_submitted, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final GetIcloudRequirementsUsecase _getRequirements;
  final ConfirmReleaseUsecase _confirmRelease;

  /// Chiqim shartnoma holatini o'zgartiradi — shartnomalar ro'yxati eskiradi.
  final ContractChanges _changes;

  _Attempt _attempt = _Attempt.requirements;

  Future<void> _started(ReleaseStarted event, Emitter<ReleaseState> emit) async {
    emit(state.copyWith(isChecking: true, clearFailure: true));

    final Result<IcloudRequirements> result = await _getRequirements(state.contract.id);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final IcloudRequirements value):
        emit(state.copyWith(isChecking: false, requirements: value));
      case Err(: final Failure failure):
        _attempt = _Attempt.requirements;
        emit(state.copyWith(isChecking: false, failure: failure));
    }
  }

  /// Surat qo'yilganda xato yozuvi ham, kamera sababi ham tozalanadi.
  void _photoTaken(PhotoTaken event, Emitter<ReleaseState> emit) => emit(
    state.copyWith(
      draft: state.draft.copyWith(photo: event.photo),
      issue: ReleaseIssue.none,
      camera: CameraIssue.none,
    ),
  );

  void _cameraRefused(CameraRefused event, Emitter<ReleaseState> emit) =>
      emit(state.copyWith(camera: event.issue));

  void _codeChanged(CodeChanged event, Emitter<ReleaseState> emit) => emit(
    state.copyWith(
      draft: state.draft.copyWith(code: event.code),
      issue: ReleaseIssue.none,
    ),
  );

  Future<void> _submitted(ReleaseSubmitted event, Emitter<ReleaseState> emit) async {
    // Talab bajarilmagan bo'lsa tugma umuman chizilmaydi; bu tekshiruv
    // holat ekranga chizilgandan keyin o'zgarib qolgan holat uchun.
    if (!state.isReady) return;

    final ReleaseIssue issue = state.draft.issue;
    final File? photo = state.draft.photo;

    if (issue != ReleaseIssue.none || photo == null) {
      emit(state.copyWith(issue: issue));
      return;
    }

    emit(state.copyWith(isSubmitting: true, issue: ReleaseIssue.none, clearFailure: true));

    final Result<void> result = await _confirmRelease(
      ReleaseParams(
        contractId: state.contract.id,
        clientId: state.contract.clientId,
        code: state.draft.code,
        photo: photo,
      ),
    );
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

  void _failureHandled(FailureHandled event, Emitter<ReleaseState> emit) =>
      emit(state.copyWith(clearFailure: true));

  /// «Qayta urinish» aynan yiqilgan amalni takrorlaydi: talab tekshiruvidan
  /// keyin tasdiqni yuborish xodim so'ramagan so'rov bo'lardi.
  void _retried(Retried event, Emitter<ReleaseState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.requirements:
        add(const ReleaseStarted());
      case _Attempt.submit:
        add(const ReleaseSubmitted());
    }
  }
}
