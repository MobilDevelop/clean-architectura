part of 'credential_bloc.dart';

/// Qaysi matn maydoni o'zgardi.
///
/// Nega bitta hodisa: o'n bitta maydonga o'n bitta hodisa yozilsa, bloc'ning
/// yarmi bir xil `copyWith` chaqiruvidan iborat bo'lardi.
enum CredentialField {
  condition,
  imei,
  imei2,
  serialNumber,
  login,
  password,
  restrictionCode,
  phone,
}

sealed class CredentialEvent extends Equatable {
  const CredentialEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class CredentialFieldChanged extends CredentialEvent {
  const CredentialFieldChanged(this.field, this.value);

  final CredentialField field;
  final String value;

  @override
  List<Object?> get props => <Object?>[field, value];
}

final class BoxSelected extends CredentialEvent {
  const BoxSelected(this.hasBox);

  final bool hasBox;

  @override
  List<Object?> get props => <Object?>[hasBox];
}

final class AppleLoginSelected extends CredentialEvent {
  const AppleLoginSelected(this.owner);

  final AppleIdOwner owner;

  @override
  List<Object?> get props => <Object?>[owner];
}

final class ApplePasswordSelected extends CredentialEvent {
  const ApplePasswordSelected(this.owner);

  final AppleIdOwner owner;

  @override
  List<Object?> get props => <Object?>[owner];
}

final class CredentialSubmitted extends CredentialEvent {
  const CredentialSubmitted();
}

final class FailureHandled extends CredentialEvent {
  const FailureHandled();
}

final class Retried extends CredentialEvent {
  const Retried();
}
