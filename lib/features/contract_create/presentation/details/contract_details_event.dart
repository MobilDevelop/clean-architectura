part of 'contract_details_bloc.dart';

sealed class ContractDetailsEvent extends Equatable {
  const ContractDetailsEvent();

  @override
  List<Object> get props => [];
}

final class DetailsRequested extends ContractDetailsEvent {
  const DetailsRequested();
}

final class FailureHandled extends ContractDetailsEvent {
  const FailureHandled();
}
