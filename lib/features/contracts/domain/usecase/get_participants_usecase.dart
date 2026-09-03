import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetParticipantsUsecase implements UseCase<List<CreditParticipant>, int> {
  const GetParticipantsUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<List<CreditParticipant>>> call(int params) => _repository.getParticipants(params);
}
