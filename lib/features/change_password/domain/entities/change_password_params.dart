import 'package:equatable/equatable.dart';

/// Yangi parolga qo'yiladigan talab. Backend ham shuni tekshiradi (7.3) —
/// juda qisqa parol serverda ham rad etiladi.
abstract final class PasswordRule {
  static const int minLength = 6;
}

/// Parolni almashtirish so'rovi.
final class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({required this.password});

  final String password;

  @override
  List<Object?> get props => <Object?>[password];
}
