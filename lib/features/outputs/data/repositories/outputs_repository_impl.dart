import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/outputs_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/data/models/output_dto.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/outputs_repository.dart';

final class OutputsRepositoryImpl implements OutputsRepository {
  const OutputsRepositoryImpl({required this._remote});

  final OutputsRemoteDatasource _remote;

  @override
  Future<Result<OutputsPageResult>> getContracts(OutputsQuery query) => guard(() async {
    final OutputsPageDto page = await _remote.getContracts(query);

    return OutputsPageResult(
      items: page.items.map((OutputContractDto dto) => dto.toEntity()).toList(),
      isLast: page.isLast,
    );
  });

  @override
  Future<Result<List<OutputProduct>>> getProducts(int contractId) => guard(() async {
    final List<OutputProductDto> list = await _remote.getProducts(contractId);

    return list.map((OutputProductDto dto) => dto.toEntity()).toList();
  });
}
