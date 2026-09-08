part of 'special_tariff_bloc.dart';

final class SpecialTariffState extends Equatable {
  const SpecialTariffState({
    required this.contractId,
    required this.termMonths,
    required this.applied,
    required this.tariffs,
    required this.isLoading,
    required this.isLoaded,
    required this.isRemoving,
    required this.revision,
    this.busyTariffId,
    this.failure,
  });

  const SpecialTariffState.initial({
    required this.contractId,
    required this.termMonths,
    required this.applied,
  }) : tariffs = const <SpecialTariff>[],
       isLoading = false,
       isLoaded = false,
       isRemoving = false,
       revision = 0,
       busyTariffId = null,
       failure = null;

  final int contractId;
  final int termMonths;

  /// Shartnomaga biriktirilgan tarif. `id == 0` — biriktirilmagan.
  final AppliedTariff applied;

  final List<SpecialTariff> tariffs;
  final bool isLoading;

  /// Javob kelgan. Bo'sh ro'yxat bilan "hali so'ralmagan" ni ajratadi.
  final bool isLoaded;

  final bool isRemoving;
  final int revision;

  /// Qaysi tarif biriktirilyapti.
  final int? busyTariffId;

  final Failure? failure;

  bool get hasApplied => applied.id != 0;

  bool get isBusy => isRemoving || busyTariffId != null;

  SpecialTariffState copyWith({
    AppliedTariff? applied,
    List<SpecialTariff>? tariffs,
    bool? isLoading,
    bool? isLoaded,
    bool? isRemoving,
    int? revision,
    int? busyTariffId,
    Failure? failure,
    bool clearFailure = false,
    bool clearBusyTariff = false,
  }) => SpecialTariffState(
    contractId: contractId,
    termMonths: termMonths,
    applied: applied ?? this.applied,
    tariffs: tariffs ?? this.tariffs,
    isLoading: isLoading ?? this.isLoading,
    isLoaded: isLoaded ?? this.isLoaded,
    isRemoving: isRemoving ?? this.isRemoving,
    revision: revision ?? this.revision,
    busyTariffId: clearBusyTariff ? null : busyTariffId ?? this.busyTariffId,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    contractId,
    termMonths,
    applied,
    tariffs,
    isLoading,
    isLoaded,
    isRemoving,
    revision,
    busyTariffId,
    failure,
  ];
}
