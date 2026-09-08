import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_details_event.dart';
part 'contract_details_state.dart';


final class ContractDetailsBloc extends Bloc<ContractDetailsEvent, ContractDetailsState> {
  ContractDetailsBloc({required this._contractId, required this._getDetails})
    : super(const ContractDetailsState.initial()) {
    on<DetailsRequested>(_requested);
    on<FailureHandled>(_failureHandled);
  }

  final int _contractId;
  final GetContractDetailsUsecase _getDetails;

  Future<void> _requested(DetailsRequested event, Emitter<ContractDetailsState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<ContractDetails> result = await _getDetails(_contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final ContractDetails value):
        emit(state.copyWith(isLoading: false, details: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<ContractDetailsState> emit) =>
      emit(state.copyWith(clearFailure: true));
}
