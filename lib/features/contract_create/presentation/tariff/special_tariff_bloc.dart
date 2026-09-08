import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/special_tariff_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'special_tariff_event.dart';
part 'special_tariff_state.dart';


/// Maxsus tarif: mavjudlarini ko'rish, biriktirish va bekor qilish.
///
/// Har amaldan keyin biriktirilgan tarif serverdan qayta o'qiladi: server uni
/// o'zi bekor qilishi mumkin va bu haqda alohida xabar bermaydi.
final class SpecialTariffBloc extends Bloc<SpecialTariffEvent, SpecialTariffState>
    with ContractWriteMixin<SpecialTariffEvent, SpecialTariffState> {
  SpecialTariffBloc({
    required int contractId,
    required int termMonths,
    required AppliedTariff applied,
    required this._getAvailable,
    required this._apply,
    required this._remove,
    required this._getApplied,
  }) : super(
         SpecialTariffState.initial(contractId: contractId, termMonths: termMonths, applied: applied),
       ) {
    on<TariffsRequested>(_requested, transformer: droppable());
    on<TariffApplied>(_applied, transformer: sequential());
    on<TariffRemoved>(_removed, transformer: sequential());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetAvailableTariffsUsecase _getAvailable;
  final ApplyTariffUsecase _apply;
  final RemoveTariffUsecase _remove;
  final GetAppliedTariffUsecase _getApplied;

  Future<void> _requested(TariffsRequested event, Emitter<SpecialTariffState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<List<SpecialTariff>> result = await _getAvailable(
      TariffQuery(contractId: state.contractId, termMonths: state.termMonths),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<SpecialTariff> value):
        emit(state.copyWith(isLoading: false, isLoaded: true, tariffs: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  Future<void> _applied(TariffApplied event, Emitter<SpecialTariffState> emit) async {
    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(busyTariffId: event.tariffId, clearFailure: true),
      run: () => _apply(
        ApplyTariffParams(
          contractId: state.contractId,
          tariffId: event.tariffId,
          termMonths: state.termMonths,
        ),
      ),
      onOk: (_) => state.copyWith(clearBusyTariff: true, revision: state.revision + 1),
      onFailure: (Failure failure) => state.copyWith(clearBusyTariff: true, failure: failure),
    );

    if (emit.isDone || state.failure != null) return;

    await _refreshApplied(emit);
  }

  Future<void> _removed(TariffRemoved event, Emitter<SpecialTariffState> emit) async {
    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(isRemoving: true, clearFailure: true),
      run: () => _remove(state.contractId),
      onOk: (_) => state.copyWith(
        isRemoving: false,
        revision: state.revision + 1,
        applied: const AppliedTariff(id: 0, name: '', isActive: false),
      ),
      onFailure: (Failure failure) => state.copyWith(isRemoving: false, failure: failure),
    );
  }

  /// Serverdagi haqiqiy holatni o'qiydi.
  ///
  /// Xatosi ko'rsatiladi: biriktirish o'tgan-o'tmagani noaniq qolsa,
  /// foydalanuvchi ekranda yolg'on holatni ko'radi (5.8).
  Future<void> _refreshApplied(Emitter<SpecialTariffState> emit) async {
    final Result<AppliedTariff> result = await _getApplied(state.contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final AppliedTariff value):
        emit(state.copyWith(applied: value));
      case Err(: final Failure failure):
        emit(state.copyWith(failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<SpecialTariffState> emit) =>
      emit(state.copyWith(clearFailure: true, clearBusyTariff: true, isRemoving: false));

  Future<void> _retried(Retried event, Emitter<SpecialTariffState> emit) async {
    emit(state.copyWith(clearFailure: true, clearBusyTariff: true, isRemoving: false));

    if (!retryLastWrite()) add(const TariffsRequested());
  }
}
