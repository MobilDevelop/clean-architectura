import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';

abstract interface class CustomerAnalysisRepository {
  Future<Result<List<CustomerAnalysis>>> getAnalyses();

  Future<Result<void>> submit(AnalysisRequest request);

  Future<Result<void>> confirmSms(AnalysisSmsParams params);
}
