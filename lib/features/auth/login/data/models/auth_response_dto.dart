import 'package:colloborator_v3/features/auth/login/data/models/user_dto.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';

/// `POST /sign-in` javobi: `{"user": {...}, "token": "..."}`
final class AuthResponseDto {
  const AuthResponseDto({required this.user, required this.token});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
        user:  UserDto.fromJson(json['user'] as Map<String, dynamic>),
        token: json['token'] as String,
      );

  final UserDto user;
  final String token;

  AuthSession toEntity() => AuthSession(user: user.toEntity(), token: token);
}