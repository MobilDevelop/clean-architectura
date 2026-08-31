import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contracts_usecase.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class ContractsBloc extends Bloc<ContractsEvent, ContractsState> {
   ContractsBloc({required this._contractsUsecase}) : super(ContractsState.initial()) {
    on<ContractsGet>(_getContracts,transformer: restartable());
    on<DateCleared>(_dateCleared);
    on<DateSelected>(_dateSelected);
    on<FailureHandled>(_failureHandler);
  }

  final ContractsUsecase _contractsUsecase;

  Future<void> _getContracts(ContractsGet event, Emitter<ContractsState> emit) async {
    emit(state.copyWith(isLoading: true,clearFailure: true));
    
    final result = await _contractsUsecase(state.filter);

    switch (result) {
      case Ok(: final value):emit(state.copyWith(isLoading: false,contracts: value));
      case Err(: final failure): emit(state.copyWith(isLoading: false,failure: failure));
    }
  }

  void _dateSelected(DateSelected event, Emitter<ContractsState> emit){
    emit(state.copyWith(filter: state.filter.copyWith(date: event.date)));
    add(const ContractsGet());
  }

  void _dateCleared(DateCleared event, Emitter<ContractsState> emit){
    emit(state.copyWith(filter: state.filter.copyWith(clearDate: true)));
    add(const ContractsGet());
  }

  void _failureHandler(FailureHandled event, Emitter<ContractsState> emit) => emit(state.copyWith(clearFailure: true));

}
