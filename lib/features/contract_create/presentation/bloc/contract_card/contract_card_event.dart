part of 'contract_card_bloc.dart';

sealed class ContractCardEvent extends Equatable {
  const ContractCardEvent();

  @override
  List<Object?> get props => [];
}

final class CardFieldChanged extends ContractCardEvent {
  const CardFieldChanged({this.phone, this.number, this.expiry});

  final String? phone;
  final String? number;
  final String? expiry;

  @override
  List<Object?> get props => [phone, number, expiry];
}

final class CardSubmitted extends ContractCardEvent {
  const CardSubmitted();
}

final class CardRemoved extends ContractCardEvent {
  const CardRemoved();
}

final class FailureHandled extends ContractCardEvent {
  const FailureHandled();
}

final class Retried extends ContractCardEvent {
  const Retried();
}
