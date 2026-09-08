import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/contract_create/data/models/skip_reason_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:dio/dio.dart';

final class KatmSkipRemoteDatasource {
  const KatmSkipRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Javob ba'zan to'g'ridan-to'g'ri ro'yxat, ba'zan `data` ichida keladi.
  Future<List<SkipReasonDto>> getReasons() async {
    final Response<dynamic> result = await _dio.get<dynamic>(Endpoints.skipReasonCategories);
    final Object? body = result.data;
    final Object? list = body is Map<String, dynamic> ? body['data'] : body;

    if (list is! List) return const <SkipReasonDto>[];

    return list.whereType<Map<String, dynamic>>().map(SkipReasonDto.fromJson).toList();
  }

  /// `success` HTTP 200 bilan ham `false` bo'lishi mumkin — shuning uchun
  /// javob repositoryga o'zi qaytariladi.
  Future<bool> turnOffKatm(KatmSkipParams params) async {
    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.turnOffKatm,
      data: <String, dynamic>{
        'contract_id': params.contractId,
        'skip_reason_category_id': params.form.reason.id,
        'reason_text': params.form.comment.trim(),
      },
    );

    return result.data?['success'] as bool? ?? false;
  }
}
