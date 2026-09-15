import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/usecase/customer_analysis_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'customer_analysis_event.dart';
part 'customer_analysis_state.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { list, submit, confirm }

/// Mijoz tahlili: so'rov ro'yxati, yangi so'rov yuborish va SMS tasdiqlash.
///
/// SMS tasdiqlash alohida blocga chiqarilmadi (`card_confirm`dan farqli):
/// u yerda server holatni oldindan aytadi va uch xil rejimga bo'linadi,
/// bu yerda esa bitta yozuvga tegishli oddiy amal — xuddi fakturani
/// ta'minotchiga yuborish kabi (`InvoicesBloc.SendRequested`).
final class CustomerAnalysisBloc extends Bloc<CustomerAnalysisEvent, CustomerAnalysisState> {
  CustomerAnalysisBloc({
    required this._getAnalyses,
    required this._submit,
    required this._confirmSms,
    required this._now,
  }) : super(const CustomerAnalysisState.initial()) {
    on<AnalysisRequested>(_requested, transformer: restartable());
    on<AnalysisSubmitted>(_submitted, transformer: droppable());
    on<SmsConfirmSubmitted>(_confirmed, transformer: droppable());
    on<SubmittedShown>(_submittedShown);
    on<ConfirmedShown>(_confirmedShown);
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final GetCustomerAnalysesUsecase _getAnalyses;
  final SubmitAnalysisUsecase _submit;
  final ConfirmAnalysisSmsUsecase _confirmSms;

  /// Muddat tekshiruvi (`CardExpiry`) testda bugungi kunga qotib qolmasligi
  /// uchun tashqaridan (9.4).
  final DateTime Function() _now;

  _Attempt _attempt = _Attempt.list;
  AnalysisRequest? _lastRequest;
  CustomerAnalysis? _lastConfirmItem;
  String _lastCode = '';

  Future<void> _requested(AnalysisRequested event, Emitter<CustomerAnalysisState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<List<CustomerAnalysis>> result = await _getAnalyses(const NoParams());
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<CustomerAnalysis> value):
        emit(state.copyWith(isLoading: false, hasLoaded: true, items: value));
      case Err(: final Failure failure):
        _attempt = _Attempt.list;
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _submitted(AnalysisSubmitted event, Emitter<CustomerAnalysisState> emit) async {
    final AnalysisRequest request = AnalysisRequest(
      inps: event.inps,
      contactPhone: event.contactPhone,
      isAdvanced: event.isAdvanced,
      card: event.card,
    );

    final AnalysisIssue issue = request.issueAt(_now());
    if (issue != AnalysisIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    _lastRequest = request;
    emit(state.copyWith(isSubmitting: true, issue: AnalysisIssue.none, clearFailure: true));

    final Result<void> result = await _submit(request);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isSubmitting: false, submitted: true));
        add(const AnalysisRequested());
      case Err(: final Failure failure):
        _attempt = _Attempt.submit;
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  Future<void> _confirmed(SmsConfirmSubmitted event, Emitter<CustomerAnalysisState> emit) async {
    if (state.confirmingId != 0) return;

    _lastConfirmItem = event.item;
    _lastCode = event.code;

    emit(state.copyWith(confirmingId: event.item.id, confirmedId: 0, clearFailure: true));

    final Result<void> result = await _confirmSms(
      AnalysisSmsParams(
        id: event.item.id,
        elmaApplicationId: event.item.elmaApplicationId,
        elmaInstanceId: event.item.elmaInstanceId,
        code: event.code,
      ),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(confirmingId: 0, confirmedId: event.item.id));
        add(const AnalysisRequested());
      case Err(: final Failure failure):
        _attempt = _Attempt.confirm;
        emit(state.copyWith(confirmingId: 0, failure: failure));
    }
  }

  void _submittedShown(SubmittedShown event, Emitter<CustomerAnalysisState> emit) =>
      emit(state.copyWith(submitted: false));

  void _confirmedShown(ConfirmedShown event, Emitter<CustomerAnalysisState> emit) =>
      emit(state.copyWith(confirmedId: 0));

  void _failureHandled(FailureHandled event, Emitter<CustomerAnalysisState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<CustomerAnalysisState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.list:
        add(const AnalysisRequested());
      case _Attempt.submit:
        final AnalysisRequest? request = _lastRequest;
        if (request != null) {
          add(
            AnalysisSubmitted(
              inps: request.inps,
              contactPhone: request.contactPhone,
              isAdvanced: request.isAdvanced,
              card: request.card,
            ),
          );
        }
      case _Attempt.confirm:
        final CustomerAnalysis? item = _lastConfirmItem;
        if (item != null) add(SmsConfirmSubmitted(item: item, code: _lastCode));
    }
  }
}
