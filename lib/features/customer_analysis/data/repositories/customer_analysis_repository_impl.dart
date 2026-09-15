import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customer_analysis/data/datasources/customer_analysis_remote_datasource.dart';
import 'package:colloborator_v3/features/customer_analysis/data/models/customer_analysis_dto.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/repositories/customer_analysis_repository.dart';

final class CustomerAnalysisRepositoryImpl implements CustomerAnalysisRepository {
  const CustomerAnalysisRepositoryImpl({required this._remote});

  final CustomerAnalysisRemoteDatasource _remote;

  @override
  Future<Result<List<CustomerAnalysis>>> getAnalyses() => guard(() async {
    final List<CustomerAnalysisDto> dtos = await _remote.getAnalyses();

    return dtos.map((CustomerAnalysisDto dto) => dto.toEntity()).toList();
  });

  @override
  Future<Result<void>> submit(AnalysisRequest request) => guard(() => _remote.submit(request));

  @override
  Future<Result<void>> confirmSms(AnalysisSmsParams params) => guard(() => _remote.confirmSms(params));
}
