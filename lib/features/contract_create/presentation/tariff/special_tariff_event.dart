part of 'special_tariff_bloc.dart';

sealed class SpecialTariffEvent extends Equatable {
  const SpecialTariffEvent();

  @override
  List<Object?> get props => [];
}

final class TariffsRequested extends SpecialTariffEvent {
  const TariffsRequested();
}

final class TariffApplied extends SpecialTariffEvent {
  const TariffApplied(this.tariffId);

  final int tariffId;

  @override
  List<Object?> get props => [tariffId];
}

final class TariffRemoved extends SpecialTariffEvent {
  const TariffRemoved();
}

final class FailureHandled extends SpecialTariffEvent {
  const FailureHandled();
}

final class Retried extends SpecialTariffEvent {
  const Retried();
}
