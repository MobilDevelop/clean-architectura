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
    on<FailureHandled>(_failureHandler);
  }

  final LoginUseCase _loginUseCase;
  final AuthNotifier _auth;
  final DeviceInfoService _deviceInfo;

  Future<void> _onStarted(LoginStarted event, Emitter<LoginState> emit) async {
    final info = await _deviceInfo.get();

    emit(state.copyWith(deviceId: info.uniqueId));
  }

  void _onVisibilityToggled(LoginPasswordVisibilityToggled event, Emitter<LoginState> emit)=>emit(state.copyWith(showPassword: !state.showPassword));
  void _failureHandler(FailureHandled event, Emitter<LoginState> emit) => emit(state.copyWith(clearFailure: true));
  void _onLoginChanged(LoginOnChanged event, Emitter<LoginState> emit) => emit(state.copyWith(loginIssue: LoginFieldIssue.none));
  void _onPasswordChanged(PasswordOnChanged event, Emitter<LoginState> emit) => emit(state.copyWith(passwordIssue: LoginFieldIssue.none));

  Future<void> _onSubmitted(LoginSubmitted event, Emitter<LoginState> emit) async {
    final loginIssue = firstError(event.username, [notEmpty(LoginFieldIssue.empty)]) ?? LoginFieldIssue.none;
    final passwordIssue = firstError(event.password, [notEmpty(LoginFieldIssue.empty)]) ?? LoginFieldIssue.none;

    if (loginIssue != LoginFieldIssue.none || passwordIssue != LoginFieldIssue.none) {
      emit(state.copyWith(loginIssue: loginIssue, passwordIssue: passwordIssue));
      return;
    }
    
    emit(state.copyWith(isLoading: true));
    final result = await _loginUseCase(LoginParams(username: event.username, password: event.password));

    switch (result) {
      case Ok(:final value):
        final saved = await _auth.signIn(value.token);

        switch (saved) {
          case Ok(): emit(state.copyWith(isLoading: false));
          case Err(:final failure): emit(state.copyWith(isLoading: false, failure: failure));
        }

      case Err(:final failure): emit(state.copyWith(isLoading: false, failure: failure));
    }
  }
}