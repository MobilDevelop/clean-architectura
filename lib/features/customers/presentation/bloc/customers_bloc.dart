import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/customer_usecase.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_event.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  CustomersBloc({required this._customerUsecase}) : super(CustomersState.initial()) {
    on<ShowSearch>(_showSearch);
    on<FailureHandled>(_failureHandler);
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchSubmitted>(_onSubmitted);
  }

  final CustomerUsecase _customerUsecase;

  void _showSearch(ShowSearch event, Emitter<CustomersState> emit) => emit(state.copyWith(showSearch: !state.showSearch));
  void _failureHandler(FailureHandled event, Emitter<CustomersState> emit) => emit(state.copyWith(clearFailure: true));

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<CustomersState> emit) async {
  final params = CustomerSearchParams(event.query);
  emit(state.copyWith(query: params.query,searchIssue: CustomerSearchIssue.none));

  // to'liq yozilgan bo'lsa — kutmasdan qidiramiz
  if (params.isComplete) await _search(params, emit);
}

Future<void> _onSubmitted(SearchSubmitted event, Emitter<CustomersState> emit) async {
  final params = CustomerSearchParams(state.query);

  if (!params.isSearchable) {
    emit(state.copyWith(searchIssue: params.issue));
    return;
  }

  emit(state.copyWith(searchIssue: CustomerSearchIssue.none));
  await _search(params, emit);
}

Future<void> _search(CustomerSearchParams params, Emitter<CustomersState> emit) async {
  emit(state.copyWith(isLoading: true,clearFailure: true));
    
    final result = await _customerUsecase(params);

    switch (result) {
      case Ok(: final value):emit(state.copyWith(customers: value,isLoading: false));
      case Err(: final failure): emit(state.copyWith(isLoading: false,failure: failure));
    }
  }
}
