import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/data/models/occupation_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:dio/dio.dart';

final class ContractIncomeRemoteDatasource {
  const ContractIncomeRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<OccupationCatalogDto?> getOccupations() async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.occupationAutocomplete,
    );

    final Object? body = result.data;

    // Server goh `data` o'ramida, goh to'g'ridan-to'g'ri yuboradi.
    return JsonParser.object(JsonParser.field(body, 'data') ?? body, fromJson: OccupationCatalogDto.fromJson);
  }

  /// Kartani biriktiradi. Javobda qator id si keladi.
  Future<int?> addCard(AddCardParams params) async {
    final CardForm form = params.form;

    final Response<dynamic> result = await _dio.post<dynamic>(
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

    return JsonParser.field(result.data, 'id') as int?;
  }

  /// O'chirish `PUT` bilan bajariladi — backend shunday tuzilgan.
  Future<void> removeCard(RemoveCardParams params) => _dio.put<dynamic>(
    '${Endpoints.deleteLoanCard}${params.cardId}',
    data: <String, dynamic>{'loan_id': params.contractId.toString()},
  );
}
