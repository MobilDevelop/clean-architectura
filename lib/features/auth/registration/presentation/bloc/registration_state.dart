part of 'registration_bloc.dart';

final class RegistrationState extends Equatable {
  const RegistrationState({
    required this.isLoading,
    required this.partners,
    required this.isRegistered,
    required this.successMessage,
    this.selectedPartner,
    this.selectedOrganization, this.failure, 
     
  });

  const RegistrationState.initial()
      : isLoading = false,
        isRegistered = false,
        partners = const [],
        selectedPartner = null,
        selectedOrganization = null,
        failure = null,
        successMessage = '';

  final bool isLoading;
  final bool isRegistered;
  final Partner? selectedPartner;
  final String successMessage;
  final Organization? selectedOrganization;
  final List<Partner> partners;
  final Failure? failure;

  /// Ta'minotchi tanlanmaguncha filial ro'yxati ochilmaydi
  bool get canSelectOrganization => selectedPartner != null;

  /// Ikkala tanlov ham qilingandagina keyingi bosqichga o'tiladi
  bool get canContinue => selectedPartner != null && selectedOrganization != null;

  RegistrationState copyWith({
    bool? isLoading,
    List<Partner>? partners,
    Partner? selectedPartner,
    Organization? selectedOrganization,
    bool clearOrganization = false,
    bool? isRegistered,
    Failure? failure,
    String? successMessage,
    bool clearFailure = false
  }) => RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      partners: partners ?? this.partners,
      isRegistered: isRegistered ?? this.isRegistered,
      successMessage: successMessage ?? this.successMessage,
      selectedPartner: selectedPartner ?? this.selectedPartner,
      failure: clearFailure ? null : failure ?? this.failure,
      selectedOrganization: clearOrganization ? null : (selectedOrganization ?? this.selectedOrganization),
    );

  @override
  List<Object?> get props => [isLoading, selectedPartner, selectedOrganization,partners,successMessage,isRegistered,?failure];
}