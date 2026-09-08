import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:equatable/equatable.dart';

// Muvaffaqiyatli kirish natijasi: kim kirdi va qaysi token bilan.
final class AuthSession extends Equatable {
  const AuthSession({required this.user, required this.token});

  final User user;
  final String token;

  @override
  List<Object?> get props => [user, token];
}