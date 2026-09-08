import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';
import 'package:dio/dio.dart';

final class ContractGuarantorRemoteDatasource {
  const ContractGuarantorRemoteDatasource({required this._dio});

  final Dio _dio;

  /// So'rov tanasiz — parametrlar query'da. Backend shunday kutadi.
  Future<int?> addGuarantor(AddGuarantorParams params) async {
    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.addLoanGuarantor,
      queryParameters: <String, dynamic>{'loan_id': params.contractId, 'guarantor_id': params.clientId},
    );

    return result.data?['id'] as int?;
  }

  Future<void> removeGuarantor(RemoveGuarantorParams params) => _dio.delete<Map<String, dynamic>>(
    '${Endpoints.deleteLoanGuarantor}${params.rowId}',
    queryParameters: <String, dynamic>{'loan_id': params.contractId},
  );
}
