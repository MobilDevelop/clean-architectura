import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';
import 'package:colloborator_v3/features/change_password/domain/repositories/change_password_repository.dart';

final class ChangePasswordUsecase implements UseCase<void, ChangePasswordParams> {
  const ChangePasswordUsecase(this._repository);

  final ChangePasswordRepository _repository;

  @override
  Future<Result<void>> call(ChangePasswordParams params) => _repository.changePassword(params);
}
