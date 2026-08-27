import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:equatable/equatable.dart';

final class ContractsState extends Equatable {
  const ContractsState({required this.contracts, required this.isLoading, required this.errorMessage, required this.filter});

  final List<ContractInfo> contracts;
  final bool isLoading;
  final String errorMessage;
  final ContractsFilter filter;
  
  const ContractsState.initial():
   isLoading = false,
   filter = const ContractsFilter(),
   errorMessage = '',
   contracts = const [];

  ContractsState copyWith({bool? isLoading,String? errorMessage,List<ContractInfo>? contracts,ContractsFilter? filter})=>ContractsState(
    contracts: contracts ?? this.contracts,
    errorMessage: errorMessage ?? this.errorMessage,
    isLoading: isLoading ?? this.isLoading,
    filter: filter ?? this.filter
  );
  
  @override
  List<Object> get props => [contracts,isLoading,errorMessage,filter];
}
