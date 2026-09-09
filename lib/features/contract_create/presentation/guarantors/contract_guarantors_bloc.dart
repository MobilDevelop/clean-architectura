import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/guarantor_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_guarantors_event.dart';
part 'contract_guarantors_state.dart';

/// Kafillar ekrani.
///
/// Kafil tanlash oqimi bu featureda emas: u mijozlar ekranidan o'tadi va
/// oferta bilan yuz tekshiruvini talab qiladi. Bu yerga faqat natija —
/// mijozning id si va ko'rsatiladigan ma'lumoti — keladi (1.3).
final class ContractGuarantorsBloc extends Bloc<ContractGuarantorsEvent, ContractGuarantorsState>
    with ContractWriteMixin<ContractGuarantorsEvent, ContractGuarantorsState> {
  ContractGuarantorsBloc({
    required int contractId,
    required int clientId,
    required List<ContractGuarantor> guarantors,
    required this._addGuarantor,
    required this._removeGuarantor,
  }) : super(
         ContractGuarantorsState.initial(contractId: contractId, clientId: clientId, guarantors: guarantors),
       ) {
    on<GuarantorAdded>(_added, transformer: sequential());
    on<GuarantorRemoved>(_removed, transformer: sequential());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final AddGuarantorUsecase _addGuarantor;
  final RemoveGuarantorUsecase _removeGuarantor;

  Future<void> _added(GuarantorAdded event, Emitter<ContractGuarantorsState> emit) async {
    // Ikkala qoida ham serverda emas, shu yerda tekshiriladi — flex ham
    // shunday qiladi va foydalanuvchi sababni darhol ko'radi.
    if (state.isFull) {
      emit(state.copyWith(issue: GuarantorIssue.limitReached));
      return;
    }

    if (event.clientId == state.clientId) {
      emit(state.copyWith(issue: GuarantorIssue.selfGuarantee));
      return;
    }

    if (state.guarantors.any((ContractGuarantor e) => e.clientId == event.clientId)) {
      emit(state.copyWith(issue: GuarantorIssue.duplicate));
      return;
    }

    await write<int>(
      event: event,
      emit: emit,
      busy: state.copyWith(isAdding: true, issue: GuarantorIssue.none, clearFailure: true),
      run: () => _addGuarantor(AddGuarantorParams(contractId: state.contractId, clientId: event.clientId)),
      // Server qaytargan id o'zgartirilmasdan saqlanadi: o'chirish aynan shu
      // id ni kutadi (mijoz id simi yoki qator id si — backenddan so'ralgan).
      onOk: (int id) => state.copyWith(
        isAdding: false,
        revision: state.revision + 1,
        guarantors: <ContractGuarantor>[
          ...state.guarantors,
          ContractGuarantor(clientId: id, fullName: event.fullName, passport: event.passport),
        ],
      ),
      onFailure: (Failure failure) => state.copyWith(isAdding: false, failure: failure),
    );
  }

  Future<void> _removed(GuarantorRemoved event, Emitter<ContractGuarantorsState> emit) => write<void>(
    event: event,
    emit: emit,
    busy: state.copyWith(busyId: event.rowId, issue: GuarantorIssue.none, clearFailure: true),
    run: () => _removeGuarantor(RemoveGuarantorParams(rowId: event.rowId, contractId: state.contractId)),
    onOk: (_) => state.copyWith(clearBusyId: true,revision: state.revision + 1,guarantors: state.guarantors.where((ContractGuarantor e) => e.clientId != event.rowId).toList()),
    onFailure: (Failure failure) => state.copyWith(failure: failure),
  );

  void _failureHandled(FailureHandled event, Emitter<ContractGuarantorsState> emit) => emit(state.copyWith(clearFailure: true, clearBusyId: true, isAdding: false));

  Future<void> _retried(Retried event, Emitter<ContractGuarantorsState> emit) async {
    emit(state.copyWith(clearFailure: true, clearBusyId: true, isAdding: false));
    retryLastWrite();
  }
}
