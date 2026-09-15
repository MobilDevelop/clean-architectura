import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customer_analysis/data/models/customer_analysis_dto.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:dio/dio.dart';

final class CustomerAnalysisRemoteDatasource {
  const CustomerAnalysisRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Sahifalash qo'llanilmaydi: backend bu ro'yxat uchun haqiqiy
  /// sahifalashni qo'llab-quvvatlashi tasdiqlanmagan (ESLATMALAR).
  static const int _perPage = 30;

  Future<List<CustomerAnalysisDto>> getAnalyses() async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.customerAnalysis,
      queryParameters: <String, dynamic>{'per_page': _perPage},
    );

    return JsonParser.list(JsonParser.field(result.data, 'data'), fromJson: CustomerAnalysisDto.fromJson);
  }

  Future<void> submit(AnalysisRequest request) =>
      _dio.post<dynamic>(Endpoints.customerAnalysis, data: _body(request));

  Future<void> confirmSms(AnalysisSmsParams params) => _dio.post<dynamic>(
    Endpoints.confirmAnalysisSms,
    data: <String, dynamic>{
      'pre_scoring_id': params.id,
      'elma_application_id': params.elmaApplicationId,
      'elma_instance_id': params.elmaInstanceId,
      'state': '1',
      'otp_code': params.code,
    },
  );

  Map<String, dynamic> _body(AnalysisRequest request) => <String, dynamic>{
    'source': 'branch-tablet',
    'service': 'prescoring',
    'inps': request.inps,
    if (request.contactPhone.isNotEmpty) 'phone_number': '+${request.contactPhone}',
    if (request.isAdvanced)
      'client_card': <String, dynamic>{
        'phone_number': '+${request.card.phone}',
        'card_number': request.card.number,
        'validity_date': request.card.expiry,
      },
  };
}
