import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetFlexMessagesUsecase implements UseCase<List<String>, int> {
  const GetFlexMessagesUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<List<String>>> call(int params) => _repository.getFlexMessages(params);
}
