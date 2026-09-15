import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';
import 'package:colloborator_v3/features/change_password/presentation/bloc/change_password_bloc.dart';

/// «Parolni o'zgartirish» ekranining matnlari.
abstract final class ChangePasswordText {
  static const String title = "Parolni o'zgartirish";

  static const String passwordLabel = "Yangi parol";
  static const String passwordHint = "Parolni kiriting";

  static const String confirmationLabel = "Parolni takrorlang";
  static const String confirmationHint = "Parolni qaytadan kiriting";

  static const String submit = "Saqlash";
}

/// Har bir xato o'z maydoni tagida chiqadi (7.5).
abstract final class PasswordIssueText {
  static String? password(PasswordFieldIssue issue) => issue == PasswordFieldIssue.tooShort
      ? "Parol kamida ${PasswordRule.minLength} belgidan iborat bo'lishi kerak"
      : null;

  static String? confirmation(PasswordFieldIssue issue) =>
      issue == PasswordFieldIssue.mismatch ? "Parollar bir xil emas" : null;
}
