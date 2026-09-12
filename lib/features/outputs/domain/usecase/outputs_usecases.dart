import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/outputs_repository.dart';

final class GetOutputContractsUsecase implements UseCase<OutputsPageResult, OutputsQuery> {
  const GetOutputContractsUsecase(this._repository);

  final OutputsRepository _repository;

  @override
  Future<Result<OutputsPageResult>> call(OutputsQuery params) => _repository.getContracts(params);
}

final class GetOutputProductsUsecase implements UseCase<List<OutputProduct>, int> {
  const GetOutputProductsUsecase(this._repository);

  final OutputsRepository _repository;

  @override
  Future<Result<List<OutputProduct>>> call(int params) => _repository.getProducts(params);
}
