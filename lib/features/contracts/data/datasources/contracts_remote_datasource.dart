import 'dart:convert';
import 'dart:isolate';

import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_info_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_scoring_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/katm_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/mib_report_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

final class ContractsRemoteDatasource {
  ContractsRemoteDatasource({required this._dio, required this._now});

  final Dio _dio;
  final DateTime Function() _now;
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  Future<List<ContractInfoDto>> getContracts(ContractsFilter filter)async{

  final DateTime date = filter.date ?? _now();
  final String formatDate = _formatter.format(date);

   final result = await _dio.get<Map<String, dynamic>>(Endpoints.getContracts,queryParameters: {"page": filter.page,"date":formatDate,'per_page': filter.perPage,"is_mobile" : true});

   return JsonParser.list(result.data?['data'], fromJson: ContractInfoDto.fromJson);
  }

  /// Server har bir ishtirokchi uchun bitta yozuv qaytaradi: mijoz va kafillar.
  Future<List<ContractScoringDto>> getScoring(int contractId) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.contractScoring}$contractId',
    );

    return JsonParser.list(result.data?['data'], fromJson: ContractScoringDto.fromJson);
  }

  /// Flex shartnomalarida ro'yxat tepasida ko'rsatiladigan xabarlar.
  Future<List<FlexMessageDto>> getFlexMessages(int contractId) async {
    final Response<List<dynamic>> result = await _dio.get<List<dynamic>>(
      '${Endpoints.flexContracts}$contractId/error-messages',
    );

    return JsonParser.list(result.data, fromJson: FlexMessageDto.fromJson);
  }

  /// Kimda qaysi hisobot borligini aytadi — hisobotning o'zini emas.
  Future<CreditReportsDto?> getCreditReports(int contractId) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.contractScoring}$contractId/credit-reports',
    );

    return JsonParser.object(result.data, fromJson: CreditReportsDto.fromJson);
  }

  Future<MibReportDto?> getMib(MibParams params) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.contractScoring}${params.contractId}/mib',
      queryParameters: <String, dynamic>{'client_id': params.clientId},
    );

    return JsonParser.object(result.data, fromJson: MibReportDto.fromJson);
  }

  /// KATM hisoboti o'zgarmas hujjat: bir marta olingach server uni qayta
  /// hisoblamaydi. ETag sessiya davomida xotirada saqlanadi — takroriy
  /// ochishda `304` keladi va tana umuman yuborilmaydi (1.7 MB → 0 bayt).
  final Map<String, ({String etag, KatmReportDto report})> _katmCache =
      <String, ({String etag, KatmReportDto report})>{};

  /// Javob 1.7 MB gacha yetadi. `ResponseType.plain` bilan olib, JSON ni alohida
  /// izolyatda ochamiz — asosiy oqimda bu ekranni bir necha yuz millisekundga
  /// qotirib qo'yadi.
  Future<KatmReportDto?> getKatm(KatmParams params) async {
    final String key = '${params.contractId}-${params.clientId}';
    final ({String etag, KatmReportDto report})? cached = _katmCache[key];

    final Response<String> result = await _dio.get<String>(
      '${Endpoints.contractScoring}${params.contractId}/katm',
      queryParameters: <String, dynamic>{'client_id': params.clientId},
      options: Options(
        responseType: ResponseType.plain,
        headers: cached == null ? null : <String, dynamic>{'If-None-Match': cached.etag},
        // `304` xato emas — tanasiz muvaffaqiyat.
        validateStatus: (int? status) => status != null && (status == 304 || (status >= 200 && status < 300)),
      ),
    );

    if (result.statusCode == 304 && cached != null) return cached.report;

    final String? body = result.data;
    if (body == null || body.isEmpty) return null;

    final Map<String, dynamic>? json = await Isolate.run(() {
      final Object? decoded = jsonDecode(body);

      return decoded is Map<String, dynamic> ? decoded : null;
    });

    if (json == null) return null;

    final KatmReportDto dto = KatmReportDto(json);
    final String? etag = result.headers.value('etag');
    if (etag != null) _katmCache[key] = (etag: etag, report: dto);

    return dto;
  }
}