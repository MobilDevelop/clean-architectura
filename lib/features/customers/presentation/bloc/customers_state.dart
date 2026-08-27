import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:equatable/equatable.dart';

final class CustomersState extends Equatable {
  const CustomersState({required this.isLoading, required this.showSearch,required this.customers,required this.failure, required this.query});

  const CustomersState.initial(): 
  isLoading = false,
  showSearch = false,

  customers = const [],

  query = '',
  failure = null;
  

  final bool isLoading;
  final bool showSearch;

  final String query;
  final Failure? failure;
  
  final List<CustomerInfo> customers;

  CustomersState copyWith({bool? isLoading,bool? showSearch,List<CustomerInfo>? customers,Failure? failure,String? query,bool clearFailure = false})=>CustomersState(
    isLoading: isLoading ?? this.isLoading, 
    showSearch: showSearch ?? this.showSearch,
    customers: customers ?? this.customers,
    query: query ?? this.query,
    failure: clearFailure ? null : failure ?? this.failure
  );
  
  @override
  List<Object> get props => [isLoading,showSearch,customers,query,?failure];
}

