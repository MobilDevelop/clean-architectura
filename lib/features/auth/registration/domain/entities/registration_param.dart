import 'package:equatable/equatable.dart';

final class RegistrationParam extends Equatable {

  const RegistrationParam({
    required this.partnerId,
    required this.organizationId,
    required this.username,
    required this.login,
    required this.password,
    required this.phone,
  });

  
  final int partnerId;
  final int organizationId;
  final String username;
  final String login;
  final String password;
  final String phone;

  @override
  List<Object?> get props => [partnerId, organizationId, username, login, password, phone];
}