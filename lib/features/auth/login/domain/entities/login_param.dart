import 'package:equatable/equatable.dart';

// Foydalanuvchi kiritadigan narsa — shuncha.
// Qurilma ma'lumoti va FCM token bu yerda yo'q: ular transport tafsiloti,
// biznes qoidasi emas. Ularni data qatlami o'zi qo'shadi.
final class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}
