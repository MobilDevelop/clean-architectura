import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';

final class GetScoringUsecase implements UseCase<ScoringInfo, int> {
  const GetScoringUsecase(this._repository);

  final CustomerRepository _repository;

  @override
  Future<Result<ScoringInfo>> call(int params) => _repository.getScoring(params);
}
