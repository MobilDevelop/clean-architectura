part of 'contract_details_bloc.dart';

final class ContractDetailsState extends Equatable {
  const ContractDetailsState({required this.isLoading, this.details, this.failure});

  const ContractDetailsState.initial() : isLoading = false, details = null, failure = null;

  final bool isLoading;
  final ContractDetails? details;
  final Failure? failure;

  ContractDetailsState copyWith({
    bool? isLoading,
    ContractDetails? details,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractDetailsState(
    isLoading: isLoading ?? this.isLoading,
    details: details ?? this.details,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [isLoading, details, failure];
}
