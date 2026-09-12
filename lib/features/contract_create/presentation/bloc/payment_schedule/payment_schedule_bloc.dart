import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/payment_schedule_usecase.dart';
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
  PaymentScheduleBloc({required ScheduleQuery query, required this._getSchedule})
    : super(PaymentScheduleState.initial(query)) {
    on<ScheduleRequested>(_requested, transformer: droppable());
    on<FailureHandled>(_failureHandled);
  }

  final GetScheduleUsecase _getSchedule;

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

  void _failureHandled(FailureHandled event, Emitter<PaymentScheduleState> emit) =>
      emit(state.copyWith(clearFailure: true));
}
