import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/repositories/customer_analysis_repository.dart';

final class GetCustomerAnalysesUsecase implements UseCase<List<CustomerAnalysis>, NoParams> {
  const GetCustomerAnalysesUsecase(this._repository);

  final CustomerAnalysisRepository _repository;

  @override
  Future<Result<List<CustomerAnalysis>>> call(NoParams params) => _repository.getAnalyses();
}

final class SubmitAnalysisUsecase implements UseCase<void, AnalysisRequest> {
  const SubmitAnalysisUsecase(this._repository);

  final CustomerAnalysisRepository _repository;

  @override
  Future<Result<void>> call(AnalysisRequest params) => _repository.submit(params);
}

final class ConfirmAnalysisSmsUsecase implements UseCase<void, AnalysisSmsParams> {
  const ConfirmAnalysisSmsUsecase(this._repository);

  final CustomerAnalysisRepository _repository;

  @override
  Future<Result<void>> call(AnalysisSmsParams params) => _repository.confirmSms(params);
}
