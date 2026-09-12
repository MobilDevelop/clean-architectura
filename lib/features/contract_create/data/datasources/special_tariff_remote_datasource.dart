import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/data/models/special_tariff_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:dio/dio.dart';

final class SpecialTariffRemoteDatasource {
  const SpecialTariffRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<List<SpecialTariffDto>> getAvailable(TariffQuery query) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.specialTariffsAvailable,
      queryParameters: <String, dynamic>{'contract_id': query.contractId, 'term': query.termMonths},
    );

    final Object? list = JsonParser.field(result.data, 'data');
    if (list is! List) return const <SpecialTariffDto>[];

    return list.whereType<Map<String, dynamic>>().map(SpecialTariffDto.fromJson).toList();
  }

  Future<void> apply(ApplyTariffParams params) => _dio.post<dynamic>(
    Endpoints.specialTariffOf(params.contractId),
    data: <String, dynamic>{'special_tariff_id': params.tariffId, 'term': params.termMonths},
  );

  Future<void> remove(int contractId) =>
      _dio.delete<dynamic>(Endpoints.specialTariffOf(contractId));

  /// Biriktirilgan tarif. Javob `data.special_tariff` ichida keladi.
  Future<Map<String, dynamic>> getApplied(int contractId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.specialTariffOf(contractId),
    );

    final Object? data = JsonParser.field(result.data, 'data');
    final Object? tariff = data is Map<String, dynamic> ? data['special_tariff'] : null;

    return tariff is Map<String, dynamic> ? tariff : const <String, dynamic>{};
  }
}
