import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/network/paged_response.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/outputs/data/models/output_dto.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

/// Sahifa javobi: yozuvlar va bu oxirgi sahifami.
typedef OutputsPageDto = ({List<OutputContractDto> items, bool isLast});

final class OutputsRemoteDatasource {
  OutputsRemoteDatasource({required this._dio, required this._now});

  final Dio _dio;

  /// Sana tashqaridan: filtr qo'yilmasa bugungi kun olinadi va test bugun
  /// o'tib ertaga yiqilmasligi kerak (9.4).
  final DateTime Function() _now;

  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  Future<OutputsPageDto> getContracts(OutputsQuery query) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.outputContracts,
      queryParameters: <String, dynamic>{
        'date': _formatter.format(query.date ?? _now()),
        'page': query.page,
        'per_page': OutputsQuery.perPage,
        'is_mobile': true,
      },
    );

    final Object? body = result.data;
    final Map<String, dynamic> json = body is Map<String, dynamic> ? body : const <String, dynamic>{};

    final List<OutputContractDto> items = JsonParser.list(
      json['data'],
      fromJson: OutputContractDto.fromJson,
    );

    return (
      items: items,
      isLast: PagedResponse.isLast(
        json: json,
        received: items.length,
        page: query.page,
        perPage: OutputsQuery.perPage,
      ),
    );
  }

  Future<List<OutputProductDto>> getProducts(int contractId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      '${Endpoints.outputProducts}$contractId',
    );

    final Object? body = result.data;

    return JsonParser.list(
      body is Map ? body['data'] : body,
      fromJson: OutputProductDto.fromJson,
    );
  }
}
