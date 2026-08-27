sealed class LoginEvent {
  const LoginEvent();
}

/// Ekran ochildi — qurilma ID sini o'qiydi
final class LoginStarted extends LoginEvent {
  const LoginStarted();
}

final class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted({required this.username, required this.password});

  final String username;
  final String password;
}

final class LoginOnChanged extends LoginEvent {
  const LoginOnChanged({required this.value});

  final String value;
}

final class PasswordOnChanged extends LoginEvent {
  const PasswordOnChanged({required this.value});

  final String value;
}