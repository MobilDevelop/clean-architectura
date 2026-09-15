import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/auth/login/domain/repositories/auth_repository.dart';

/// Ilova qayta ochilganda oldingi profilni tarmoqsiz tiklaydi.
final class RestoreSessionUsecase implements UseCase<User?, NoParams> {
  const RestoreSessionUsecase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<User?>> call(NoParams params) => _repository.restoreSession();
}
