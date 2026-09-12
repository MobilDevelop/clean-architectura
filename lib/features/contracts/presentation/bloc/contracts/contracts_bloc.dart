import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contracts_usecase.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts/contracts_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts/contracts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
   ContractsBloc({required this._contractsUsecase, required this._push, required this._changes})
    : super(ContractsState.initial()) {
    on<ContractsGet>(_getContracts,transformer: restartable());
    on<DateCleared>(_dateCleared);
    on<DateSelected>(_dateSelected);
    on<FailureHandled>(_failureHandler);
    on<PushReceived>(_pushReceived);
    on<ContractsStale>(_contractsStale);
    on<PushOpened>(_pushOpened);
    on<ContractOpened>(_contractOpened);

    // Faqat shartnomaga tegishli xabar ro'yxatni eskirtiradi — boshqasidan
    // keyin so'rov yuborish serverni behuda urardi (flex ham shunday qiladi).
    _received = _push.received.listen((PushMessage message) {
      if (message.hasContract) add(const PushReceived());
    });

    _opened = _push.opened.listen((_) => add(const PushOpened()));

    // Shartnoma boshqa ekranda yuborildi.
    _stale = _changes.changes.listen((ContractChange change) => add(ContractsStale(change)));

    // Sovuq start: bildirishnoma bloc yaratilishidan oldin bosilgan bo'lishi
    // mumkin va oqim uni saqlamaydi — kutib turgani shu yerda olinadi.
    add(const PushOpened());
  }

  final ContractsUsecase _contractsUsecase;
  final PushNotifications _push;
  final ContractChanges _changes;

  StreamSubscription<PushMessage>? _received;
  StreamSubscription<PushMessage>? _opened;
  StreamSubscription<ContractChange>? _stale;

  Future<void> _getContracts(ContractsGet event, Emitter<ContractsState> emit) async {
    emit(state.copyWith(isLoading: true,clearFailure: true));
    
    final result = await _contractsUsecase(state.filter);

    switch (result) {
      case Ok(: final value):emit(state.copyWith(isLoading: false,contracts: value));
      case Err(: final failure): emit(state.copyWith(isLoading: false,failure: failure));
    }
  }

  void _pushReceived(PushReceived event, Emitter<ContractsState> emit) => add(const ContractsGet());

  /// Ro'yxat boshqa ekrandagi yozuvdan keyin eskirdi.
  ///
  /// Yangi shartnomada sana filtri tozalanadi: u bugungi kun bilan yaratiladi
  /// va eski sanaga qo'yilgan filtr uni yashirib qo'yardi — foydalanuvchi aynan
  /// shu shartnomani ko'rish uchun bu yerga olib kelinadi (5.8). Tahrirda esa
  /// yangi qator paydo bo'lmaydi, shuning uchun filtrga tegilmaydi.
  void _contractsStale(ContractsStale event, Emitter<ContractsState> emit) {
    if (event.change == ContractChange.created) {
      emit(state.copyWith(filter: state.filter.copyWith(clearDate: true)));
    }

    add(const ContractsGet());
  }

  /// Bildirishnoma bosildi.
  ///
  /// Sana filtri tozalanadi: push kelgan shartnoma odatda bugungi emas va
  /// filtr uni ro'yxatdan yashirib qo'yardi — foydalanuvchi bosgan xabar
  /// hech qayerga olib bormasdi (5.8).
  void _pushOpened(PushOpened event, Emitter<ContractsState> emit) {
    final PushMessage? message = _push.takePending();
    if (message == null || !message.hasContract) return;

    emit(state.copyWith(
      filter: state.filter.copyWith(clearDate: true),
      openContractId: message.contractId,
    ));

    add(const ContractsGet());
  }

  void _contractOpened(ContractOpened event, Emitter<ContractsState> emit) =>
      emit(state.copyWith(openContractId: 0));

  void _dateSelected(DateSelected event, Emitter<ContractsState> emit){
    emit(state.copyWith(filter: state.filter.copyWith(date: event.date)));
    add(const ContractsGet());
  }

  void _dateCleared(DateCleared event, Emitter<ContractsState> emit){
    emit(state.copyWith(filter: state.filter.copyWith(clearDate: true)));
    add(const ContractsGet());
  }

  void _failureHandler(FailureHandled event, Emitter<ContractsState> emit) => emit(state.copyWith(clearFailure: true));

  @override
  Future<void> close() async {
    await _received?.cancel();
    await _opened?.cancel();
    await _stale?.cancel();

    return super.close();
  }
}
