import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/registration_param.dart';
import 'package:colloborator_v3/features/auth/registration/domain/repositories/registration_repository.dart';

final class RegistrationUsecase implements UseCase<String, RegistrationParam> {
  const RegistrationUsecase(this._repository);

  final RegistrationRepository _repository;

  @override
  Future<Result<String>> call(RegistrationParam params) => _repository.registration(params);
}