import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/manager_bonus_repository.dart';

final class SendBonusUsecase implements UseCase<void, SendBonusParams> {
  const SendBonusUsecase(this._repository);

  final ManagerBonusRepository _repository;

  @override
  Future<Result<void>> call(SendBonusParams params) => _repository.sendDecision(params);
}
