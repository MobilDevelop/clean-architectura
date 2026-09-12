import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';

abstract interface class OutputsRepository {
  Future<Result<OutputsPageResult>> getContracts(OutputsQuery query);

  Future<Result<List<OutputProduct>>> getProducts(int contractId);
}
