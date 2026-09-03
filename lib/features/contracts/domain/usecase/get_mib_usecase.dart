import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetMibUsecase implements UseCase<MibReport, MibParams> {
  const GetMibUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<MibReport>> call(MibParams params) => _repository.getMib(params);
}
