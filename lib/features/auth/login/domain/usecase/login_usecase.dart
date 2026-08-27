import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';
import 'package:colloborator_v3/features/auth/login/domain/repositories/auth_repository.dart';

// Tizimga kirish amali. Hozircha repository'ni chaqiradi, xolos —
// lekin kirish oldidagi yoki keyingi qoidalar paydo bo'lsa, ular shu yerga tushadi.
final class  LoginUseCase implements UseCase<AuthSession, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<AuthSession>> call(LoginParams params) => _repository.login(params);
}