import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/payment_schedule_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/schedule_pdf.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'payment_schedule_event.dart';
part 'payment_schedule_state.dart';


/// To'lov jadvali — faqat o'qish.
///
/// Muddat va to'lov kuni so'rovda ketadi: ular hali qoralamaga saqlanmagan
/// bo'lishi mumkin. Flex bo'sh javob bilan tarmoq xatosini farqlamas edi —
/// bu yerda ikkalasi alohida holat.
final class PaymentScheduleBloc extends Bloc<PaymentScheduleEvent, PaymentScheduleState> {
  PaymentScheduleBloc({
    required ScheduleQuery query,
    required this._clientName,
    required this._getSchedule,
    required this._now,
  }) : super(PaymentScheduleState.initial(query)) {
    on<ScheduleRequested>(_requested, transformer: droppable());
    on<ScheduleShareRequested>(_shareRequested, transformer: droppable());
    on<ScheduleFileShared>(_fileShared);
    on<FailureHandled>(_failureHandled);
  }

  final GetScheduleUsecase _getSchedule;

  /// Hujjat sarlavhasida turadi — mijoz bu qaysi shartnoma ekanini bilishi
  /// kerak.
  final String _clientName;

  /// Vaqt tashqaridan (9.4).
  final DateTime Function() _now;

  Future<void> _requested(ScheduleRequested event, Emitter<PaymentScheduleState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<PaymentSchedule> result = await _getSchedule(state.query);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final PaymentSchedule value):
        emit(state.copyWith(isLoading: false, schedule: value, isLoaded: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// PDF yasash bir necha yuz millisekund oladi — tugmada aylanish belgisi
  /// turishi kerak, aks holda bosish javobsiz qolgandek ko'rinadi.
  Future<void> _shareRequested(
    ScheduleShareRequested event,
    Emitter<PaymentScheduleState> emit,
  ) async {
    if (!state.canShare) return;

    emit(state.copyWith(isSharing: true, clearShareFile: true, clearFailure: true));

    try {
      final File file = await SchedulePdf.build(
        schedule: state.schedule,
        contractId: state.query.contractId,
        clientName: _clientName,
        now: _now(),
      );

      if (emit.isDone) return;

      emit(state.copyWith(isSharing: false, shareFile: file));
    } catch (_) {
      if (emit.isDone) return;

      // Sabab foydalanuvchiga emas: u shrift yoki disk muammosi. Ekranda
      // nima bo'lganini aytadigan xabar turadi (5.8).
      emit(
        state.copyWith(
          isSharing: false,
          failure: const UnknownFailure('Jadvalni faylga aylantirib bo\'lmadi'),
        ),
      );
    }
  }

  void _fileShared(ScheduleFileShared event, Emitter<PaymentScheduleState> emit) =>
      emit(state.copyWith(clearShareFile: true));

  void _failureHandled(FailureHandled event, Emitter<PaymentScheduleState> emit) =>
      emit(state.copyWith(clearFailure: true));
}
