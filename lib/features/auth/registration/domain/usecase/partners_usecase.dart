import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/partner.dart';
import 'package:colloborator_v3/features/auth/registration/domain/repositories/registration_repository.dart';

final class PartnersUsecase implements UseCase<List<Partner>, String> {
  const PartnersUsecase(this._repository);

  final RegistrationRepository _repository;

  @override
  Future<Result<List<Partner>>> call(String search) => _repository.getPartners(search);
}