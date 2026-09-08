import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/katm_skip_repository.dart';

final class GetSkipReasonsUsecase implements UseCase<List<SkipReason>, NoParams> {
  const GetSkipReasonsUsecase(this._repository);

  final KatmSkipRepository _repository;

  @override
  Future<Result<List<SkipReason>>> call(NoParams params) => _repository.getReasons();
}

final class TurnOffKatmUsecase implements UseCase<void, KatmSkipParams> {
  const TurnOffKatmUsecase(this._repository);

  final KatmSkipRepository _repository;

  @override
  Future<Result<void>> call(KatmSkipParams params) => _repository.turnOffKatm(params);
}
