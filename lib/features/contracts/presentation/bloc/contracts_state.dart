import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:equatable/equatable.dart';

final class ContractsState extends Equatable {
  const ContractsState({required this.contracts, required this.isLoading, required this.filter, this.failure});

  final List<ContractInfo> contracts;
  final bool isLoading;
  final ContractsFilter filter;
  final Failure? failure;
  
  const ContractsState.initial():
   failure = null,
   isLoading = false,
   filter = const ContractsFilter(),
   contracts = const [];

  ContractsState copyWith({bool? isLoading,List<ContractInfo>? contracts,ContractsFilter? filter,Failure? failure,bool clearFailure = false})=>ContractsState(
    filter: filter ?? this.filter,
    contracts: contracts ?? this.contracts,
    isLoading: isLoading ?? this.isLoading,
    failure: clearFailure ? null : failure ?? this.failure
  );
  
  @override
  List<Object> get props => [contracts,isLoading,filter,?failure];
}
