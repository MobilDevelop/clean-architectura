part of 'registration_bloc.dart';

sealed class RegistrationEvent {
  const RegistrationEvent();
}

final class SearchPartnersChanged extends RegistrationEvent {
  const SearchPartnersChanged({required this.search});

   final String search;
}

final class SelectedPartnerChanged extends RegistrationEvent {
  const SelectedPartnerChanged({required this.partner});

  final Partner partner;
}

final class SelectedOrganizationChanged extends RegistrationEvent {
  const SelectedOrganizationChanged({required this.organization});

  final Organization organization;
}

final class ErrorShown extends RegistrationEvent {
  const ErrorShown();
}

final class SuccessShown extends RegistrationEvent {
  const SuccessShown();
}

final class RegistrationSendData extends RegistrationEvent{
  const RegistrationSendData({required this.fullname, required this.login, required this.password, required this.phone});
  
  final String fullname;
  final String login;
  final String password;
  final String phone;
}