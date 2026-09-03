import 'dart:io';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_form.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/check_client_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'face_id_event.dart';
part 'face_id_state.dart';

final class FaceIdBloc extends Bloc<FaceIdEvent, FaceIdState> {
  FaceIdBloc({required this._checkClientUsecase, required this._now})
    : super(const FaceIdState.initial()) {
    on<SeriesChanged>(_seriesChanged);
    on<NumberChanged>(_numberChanged);
    on<BirthdayChanged>(_birthdayChanged);
    on<OfferAccepted>(_offerAccepted);
    on<CaptureRequested>(_captureRequested);
    on<CaptureCancelled>(_captureCancelled);
    on<PhotoCaptured>(_photoCaptured);
    on<CheckRetried>(_checkRetried);
    on<FailureHandled>(_failureHandled);
  }

  final CheckClientUsecase _checkClientUsecase;
  final DateTime Function() _now;

  // Foydalanuvchi tuzata boshlaganda xato yo'qoladi.
  void _seriesChanged(SeriesChanged event, Emitter<FaceIdState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(series: event.value), issue: FaceCheckIssue.none));

  void _numberChanged(NumberChanged event, Emitter<FaceIdState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(number: event.value), issue: FaceCheckIssue.none));

  void _birthdayChanged(BirthdayChanged event, Emitter<FaceIdState> emit) => emit(state.copyWith(form: state.form.copyWith(birthday: event.value), issue: FaceCheckIssue.none));

  void _offerAccepted(OfferAccepted event, Emitter<FaceIdState> emit) =>
      emit(state.copyWith(isOfferAccepted: event.value, issue: FaceCheckIssue.none));

  /// Xato bo'lsa kamera ochilmaydi — aks holda rasm olinib, keyin "pasport
  /// to'liq emas" deyilardi.
  void _captureRequested(CaptureRequested event, Emitter<FaceIdState> emit) {
    // Rozilik yozuvisiz kamera ochilmaydi. Buni tugmaning rangi emas, qoida
    // ushlab turishi kerak (6.7).
    if (!state.isOfferAccepted) {
      emit(state.copyWith(issue: FaceCheckIssue.offerNotAccepted));
      return;
    }

    final FaceCheckIssue issue = state.form.issueAt(_now());

    if (issue != FaceCheckIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    emit(state.copyWith(cameraOpen: true));
  }

  void _captureCancelled(CaptureCancelled event, Emitter<FaceIdState> emit) => emit(state.copyWith(cameraOpen: false));

  Future<void> _photoCaptured(PhotoCaptured event, Emitter<FaceIdState> emit) => _send(event.image, emit);

  Future<void> _checkRetried(CheckRetried event, Emitter<FaceIdState> emit) async {
    final File? image = state.image;
    if (image == null) return;

    await _send(image, emit);
  }

  Future<void> _send(File image, Emitter<FaceIdState> emit) async {
    emit(state.copyWith(image: image, cameraOpen: false, isLoading: true, clearFailure: true, clearCustomer: true));

    final Result<CustomerInfo> result = await _checkClientUsecase(state.form.withImage(image));

    switch (result) {
      case Ok(: final CustomerInfo value):
        emit(state.copyWith(isLoading: false, customerInfo: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<FaceIdState> emit) => emit(state.copyWith(clearFailure: true));
}
