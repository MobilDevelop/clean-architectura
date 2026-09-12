import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/card_confirmation_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:dio/dio.dart';

final class CardConfirmRemoteDatasource {
  const CardConfirmRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Javob `data` ichida keladi.
  Future<CardConfirmationDto?> get(int contractId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      '${Endpoints.smsForCardConfirmation}$contractId',
    );

    final Object? body = result.data;
    final Object? data = body is Map ? body['data'] : null;

    return JsonParser.object(data, fromJson: CardConfirmationDto.fromJson);
  }

  Future<void> submit(CardConfirmParams params) =>
      _dio.post<dynamic>(Endpoints.giveSmsCodeToElma, data: _body(params));

  /// So'rov tanasi. `card` bo'limi faqat karta saqlanayotganda qo'shiladi —
  /// boshqa amallarda server uni kutmaydi.
  Map<String, dynamic> _body(CardConfirmParams params) {
    final CardConfirmation data = params.confirmation;
    final bool isCode = params.action == CardConfirmAction.code;

    return <String, dynamic>{
      if (isCode) 'otp_code': params.code.trim(),
      'state': params.action.value,
      'contract_id': data.contractId,
      'elma_application_id': data.elmaApplicationId,
      'elma_instance_id': data.elmaInstanceId,
      'card_id': data.cardId,
      if (params.action == CardConfirmAction.saveCard)
        'card': <String, dynamic>{
          'card_number': params.entry.number,
          'phone_number': params.entry.phone,
          'validity_date': params.entry.expiry,
          'validity_month': params.entry.month,
          'validity_year': params.entry.year,
        },
    };
  }
}
