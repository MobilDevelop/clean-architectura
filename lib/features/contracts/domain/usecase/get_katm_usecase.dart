import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetKatmUsecase implements UseCase<KatmReport, KatmParams> {
  const GetKatmUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<KatmReport>> call(KatmParams params) => _repository.getKatm(params);
}
