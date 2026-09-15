part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({required this.password, required this.confirmation});

  final String password;

  /// Faqat shakl tekshiruvi uchun — serverga yuborilmaydi (7.2).
  final String confirmation;

  @override
  List<Object?> get props => <Object?>[password, confirmation];
}

final class FailureHandled extends ChangePasswordEvent {
  const FailureHandled();
}

final class Retried extends ChangePasswordEvent {
  const Retried();
}
