import 'package:colloborator_v3/core/error/failure.dart';
import 'package:equatable/equatable.dart';

enum LoginFieldIssue { none, empty }

final class LoginState extends Equatable {
  const LoginState({
    required this.showPassword,
    required this.isLoading,
    required this.loginIssue,
    required this.passwordIssue,
    required this.deviceId,
    this.failure
  });

  const LoginState.initial()
      : showPassword = false,
        isLoading = false,
        loginIssue = LoginFieldIssue.none,
        passwordIssue = LoginFieldIssue.none,
        failure = null,
        deviceId = '';

  final bool showPassword;
  final bool isLoading;

  final LoginFieldIssue loginIssue;
  final LoginFieldIssue passwordIssue;

  final Failure? failure;

  /// Kirish rad etilganda ekranda ko'rsatiladi — qo'llab-quvvatlash xizmati
  /// qurilmani shu ID bo'yicha ro'yxatga oladi
  final String deviceId;

  LoginState copyWith({bool? showPassword, bool? isLoading, String? deviceId,LoginFieldIssue? loginIssue,LoginFieldIssue? passwordIssue,Failure? failure,bool clearFailure = false}) => LoginState(
        showPassword: showPassword ?? this.showPassword,
        isLoading: isLoading ?? this.isLoading,
        loginIssue: loginIssue ?? this.loginIssue,
        passwordIssue: passwordIssue ?? this.passwordIssue,
        deviceId: deviceId ?? this.deviceId,
        failure: clearFailure ? null : failure ?? this.failure
      );

  @override
  List<Object?> get props => [showPassword, isLoading, deviceId,loginIssue,passwordIssue,failure];
}