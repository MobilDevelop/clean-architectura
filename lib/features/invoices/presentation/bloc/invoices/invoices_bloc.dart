import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/domain/usecase/invoices_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'invoices_event.dart';
part 'invoices_state.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { list, send }

/// Fakturalar ro'yxati va yuk xatini ta'minotchiga yuborish.
final class InvoicesBloc extends Bloc<InvoicesEvent, InvoicesState> {
  InvoicesBloc({required this._getInvoices, required this._send})
    : super(const InvoicesState.initial()) {
    on<InvoicesRequested>(_requested, transformer: restartable());
    on<NextPageRequested>(_nextPage, transformer: droppable());
    on<DateSelected>(_dateSelected);
    on<DateCleared>(_dateCleared);
    // `droppable`: yuborish tashqi tomonga ketadigan amal — ikkinchi bosish
    // ikkinchi xabar yubormaydi.
    on<SendRequested>(_sendRequested, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final GetInvoicesUsecase _getInvoices;
  final SendInvoiceUsecase _send;

  _Attempt _attempt = _Attempt.list;

  /// Oxirgi yuborishga urinilgan faktura — «Qayta urinish» shuni takrorlaydi.
  Invoice? _lastSent;

  Future<void> _requested(InvoicesRequested event, Emitter<InvoicesState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true, query: state.query.copyWith(page: 1)));

    final Result<InvoicesPageResult> result = await _getInvoices(state.query);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final InvoicesPageResult value):
        emit(
          state.copyWith(
            isLoading: false,
            hasLoaded: true,
            invoices: value.items,
            isLast: value.isLast,
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.list;
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Keyingi sahifa. Oxirgi sahifadan keyin so'rov yuborilmaydi.
  Future<void> _nextPage(NextPageRequested event, Emitter<InvoicesState> emit) async {
    if (state.isLast || state.isLoading || state.isPageLoading || state.invoices.isEmpty) return;

    final InvoicesQuery next = state.query.copyWith(page: state.query.page + 1);

    emit(state.copyWith(isPageLoading: true, clearFailure: true));

    final Result<InvoicesPageResult> result = await _getInvoices(next);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final InvoicesPageResult value):
        emit(
          state.copyWith(
            isPageLoading: false,
            // Sahifa raqami faqat muvaffaqiyatdan keyin oshadi: aks holda
            // yiqilgan so'rovdan keyin bitta sahifa butunlay tushib qolardi.
            query: next,
            invoices: <Invoice>[...state.invoices, ...value.items],
            isLast: value.isLast,
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.list;
        emit(state.copyWith(isPageLoading: false, failure: failure));
    }
  }

  void _dateSelected(DateSelected event, Emitter<InvoicesState> emit) {
    emit(state.copyWith(query: state.query.copyWith(date: event.date, page: 1)));
    add(const InvoicesRequested());
  }

  void _dateCleared(DateCleared event, Emitter<InvoicesState> emit) {
    emit(state.copyWith(query: state.query.copyWith(clearDate: true, page: 1)));
    add(const InvoicesRequested());
  }

  Future<void> _sendRequested(SendRequested event, Emitter<InvoicesState> emit) async {
    if (state.sendingId != 0) return;

    _lastSent = event.invoice;

    emit(state.copyWith(sendingId: event.invoice.id, sentId: 0, clearFailure: true));

    final Result<void> result = await _send(event.invoice.waybillId);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(sendingId: 0, sentId: event.invoice.id));
      case Err(: final Failure failure):
        _attempt = _Attempt.send;
        emit(state.copyWith(sendingId: 0, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<InvoicesState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<InvoicesState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.list:
        add(const InvoicesRequested());
      case _Attempt.send:
        final Invoice? invoice = _lastSent;
        if (invoice != null) add(SendRequested(invoice));
    }
  }
}
