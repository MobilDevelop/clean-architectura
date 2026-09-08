part of 'contract_create_bloc.dart';

sealed class ContractCreateEvent extends Equatable {
  const ContractCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Ekran ochildi yoki serverda biror narsa o'zgardi — shartnoma so'raladi.
final class ContractRequested extends ContractCreateEvent {
  const ContractRequested();
}

/// Tovarlar ekrani qoralama yaratgan bo'lishi mumkin.
final class ContractIdReceived extends ContractCreateEvent {
  const ContractIdReceived(this.contractId);

  final int contractId;

  @override
  List<Object?> get props => [contractId];
}

final class TermChanged extends ContractCreateEvent {
  const TermChanged(this.value);

  final int value;

  @override
  List<Object?> get props => [value];
}

final class PaymentDaySelected extends ContractCreateEvent {
  const PaymentDaySelected(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class BasisChanged extends ContractCreateEvent {
  const BasisChanged(this.basis);

  final IncomeBasis basis;

  @override
  List<Object?> get props => [basis];
}

final class CarIncomeToggled extends ContractCreateEvent {
  const CarIncomeToggled();
}

final class OccupationSelected extends ContractCreateEvent {
  const OccupationSelected(this.occupation);

  final OccupationType occupation;

  @override
  List<Object?> get props => [occupation];
}

final class SubmitRequested extends ContractCreateEvent {
  const SubmitRequested();
}

final class FailureHandled extends ContractCreateEvent {
  const FailureHandled();
}

final class Retried extends ContractCreateEvent {
  const Retried();
}
