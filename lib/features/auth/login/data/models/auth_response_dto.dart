import 'package:colloborator_v3/features/auth/login/data/models/user_dto.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';

/// `POST /sign-in` javobi: `{"user": {...}, "token": "..."}`
final class AuthResponseDto {
  const AuthResponseDto({required this.user, required this.userJson, required this.token});

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> userJson = json['user'] as Map<String, dynamic>;

    return AuthResponseDto(
      user: UserDto.fromJson(userJson),
      userJson: userJson,
      token: json['token'] as String,
    );
  }

  final UserDto user;

  /// Xom shakl — sessiyani tiklash uchun saqlanadi (`SecureUserStorage`).
  /// `UserDto`ning o'zi buni orqaga `toJson` bilan qaytarmaydi: ikkita
  /// joyda bir xil shaklni yozish ularni asta-sekin bir-biridan
  /// uzoqlashtirardi.
  final Map<String, dynamic> userJson;

  final String token;

  AuthSession toEntity() => AuthSession(user: user.toEntity(), token: token);
}