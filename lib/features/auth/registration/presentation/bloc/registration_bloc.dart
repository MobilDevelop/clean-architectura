import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/organization.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/partner.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/registration_param.dart';
import 'package:colloborator_v3/features/auth/registration/domain/usecase/partners_usecase.dart';
import 'package:colloborator_v3/features/auth/registration/domain/usecase/registration_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'registration_event.dart';
part 'registration_state.dart';

final class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  RegistrationBloc({required this._partnerUsecase, required this._registrationUsecase}) : super(RegistrationState.initial()) {
    on<SearchPartnersChanged>(_searchPartners);
    on<SelectedPartnerChanged>(_selectPartner);
    on<SelectedOrganizationChanged>(_selectOrganization);
    on<RegistrationSendData>(_sendData);
    on<FailureHandled>(_failureHandled);
    on<SuccessShown>(_successShown);
  }

  final PartnersUsecase _partnerUsecase;
  final RegistrationUsecase _registrationUsecase;

  Future<void> _searchPartners(SearchPartnersChanged event, Emitter<RegistrationState> emit) async {
     emit(state.copyWith(isLoading: true,clearFailure: true));

     final result = await _partnerUsecase(event.search);

     switch (result) {
      case Ok(:final value): emit(state.copyWith(isLoading: false,partners: value));
      case Err(:final failure): emit(state.copyWith(isLoading: false,failure: failure));
    }
  }

  Future<void> _sendData(RegistrationSendData event, Emitter<RegistrationState> emit) async {
    emit(state.copyWith(isLoading: true,clearFailure: true));

    final result = await _registrationUsecase(
      RegistrationParam(
        username: event.fullname,
        login: event.login,
        password: event.password,
        phone: event.phone,
        partnerId: state.selectedPartner?.id ?? 0,
        organizationId: state.selectedOrganization?.id ?? 0,
      )
    );

    switch (result) {
      case Ok(:final value): emit(state.copyWith(isLoading: false,isRegistered: true,successMessage: value));
      case Err(:final failure): emit(state.copyWith(isLoading: false,failure: failure));
    }
  }

  Future<void> _selectOrganization(SelectedOrganizationChanged event, Emitter<RegistrationState> emit) async {
    emit(state.copyWith(selectedOrganization: event.organization));
  }

  Future<void> _selectPartner(SelectedPartnerChanged event, Emitter<RegistrationState> emit) async {
    emit(state.copyWith(selectedPartner: event.partner, clearOrganization: true));
  }

  void _failureHandled(FailureHandled event, Emitter<RegistrationState> emit)=>emit(state.copyWith(clearFailure: true));

  void _successShown(SuccessShown event, Emitter<RegistrationState> emit)=>emit(state.copyWith(successMessage: '',isRegistered: false));
}