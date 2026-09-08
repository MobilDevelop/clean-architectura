import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/data/models/occupation_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:dio/dio.dart';

final class ContractIncomeRemoteDatasource {
  const ContractIncomeRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<OccupationCatalogDto?> getOccupations() async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.occupationAutocomplete,
    );

    final Map<String, dynamic>? body = result.data;

    return JsonParser.object(body?['data'] ?? body, fromJson: OccupationCatalogDto.fromJson);
  }

  /// Kartani biriktiradi. Javobda qator id si keladi.
  Future<int?> addCard(AddCardParams params) async {
    final CardForm form = params.form;

    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.addLoanCard,
      data: <String, dynamic>{
        'loan_id': params.contractId,
        'client_id': params.clientId,
        'client_card': <String, dynamic>{
          'number': form.number,
          'validity_year': form.year,
          'validity_month': form.month,
          'phone_number': '+${form.phone}',
        },
      },
    );

    return result.data?['id'] as int?;
  }

  /// O'chirish `PUT` bilan bajariladi — backend shunday tuzilgan.
  Future<void> removeCard(RemoveCardParams params) => _dio.put<Map<String, dynamic>>(
    '${Endpoints.deleteLoanCard}${params.cardId}',
    data: <String, dynamic>{'loan_id': params.contractId.toString()},
  );
}
