import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/device_info_service.dart';
import 'package:colloborator_v3/core/utils/validator/rules.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';
import 'package:colloborator_v3/features/auth/login/domain/usecase/login_usecase.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_event.dart';
import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final class 
LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this._loginUseCase, required this._auth,required this._deviceInfo}) : super(const LoginState.initial()) {
    on<LoginStarted>(_onStarted);
    on<LoginPasswordVisibilityToggled>(_onVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginOnChanged>(_onLoginChanged);
    on<PasswordOnChanged>(_onPasswordChanged);
  }

  final LoginUseCase _loginUseCase;
  final AuthNotifier _auth;
  final DeviceInfoService _deviceInfo;

  Future<void> _onStarted(LoginStarted event, Emitter<LoginState> emit) async {
    final info = await _deviceInfo.get();

    emit(state.copyWith(deviceId: info.uniqueId));
  }

  void _onVisibilityToggled(LoginPasswordVisibilityToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(showPassword: !state.showPassword));
  }

  void _onLoginChanged(LoginOnChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(loginError: event.value.isNotEmpty ? '' : null));
  }

  void _onPasswordChanged(PasswordOnChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(passwordError: event.value.isNotEmpty ? '' : null));
  }

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    final usernameError = firstError(event.username, [notEmpty('Login kiritilmadi')]);
    final passwordError = firstError(event.password, [notEmpty('Parol kiritilmadi')]);

    if (usernameError != null || passwordError != null) {
      emit(state.copyWith(loginError: usernameError ?? '',passwordError: passwordError ?? '',errorMessage: ''));
      return;
    }
    
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    final result = await _loginUseCase(LoginParams(username: event.username, password: event.password));

    switch (result) {
      case Ok(:final value):
        try {
          await _auth.signIn(value.token);
          emit(state.copyWith(isLoading: false));
        } catch (_) {
          emit(state.copyWith(isLoading: false,errorMessage: "Kirish ma'lumotini saqlab bo'lmadi. Qayta urinib ko'ring."));
        }

      case Err(:final failure): emit(state.copyWith(isLoading: false, errorMessage: failure.message));
    }
  }
}