import 'package:equatable/equatable.dart';

final class LoginState extends Equatable {
  const LoginState({
    required this.showPassword,
    required this.isLoading,
    required this.errorMessage,
    required this.loginError,
    required this.passwordError,
    required this.deviceId,
  });

  const LoginState.initial()
      : showPassword = false,
        isLoading = false,
        errorMessage = '',
        passwordError = '',
        loginError = '',
        deviceId = '';

  final bool showPassword;
  final bool isLoading;

  final String errorMessage;
  final String loginError;
  final String passwordError;

  /// Kirish rad etilganda ekranda ko'rsatiladi — qo'llab-quvvatlash xizmati
  /// qurilmani shu ID bo'yicha ro'yxatga oladi
  final String deviceId;

  LoginState copyWith({bool? showPassword, bool? isLoading, String? errorMessage, String? deviceId,String? loginError,String? passwordError}) => LoginState(
        showPassword: showPassword ?? this.showPassword,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        loginError: loginError ?? this.loginError,
        passwordError: passwordError ?? this.passwordError,
        deviceId: deviceId ?? this.deviceId,
      );

  @override
  List<Object?> get props => [showPassword, isLoading, errorMessage, deviceId,loginError,passwordError];
}