import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/contract_create/data/models/guarantor_instruments_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:dio/dio.dart';

final class GuarantorInstrumentsRemoteDatasource {
  const GuarantorInstrumentsRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<GuarantorInstrumentsDto> load(GuarantorRef ref) async {
    final Response<dynamic> response = await _dio.get<dynamic>(Endpoints.guarantorInstruments(ref.contractId, ref.clientId));

    return GuarantorInstrumentsDto.fromJson(_body(response.data));
  }

  Future<GuarantorInstrumentsDto> save(SaveInstrumentsParams params) async {
    final InstrumentCardDraft? card = params.card;

    final Response<dynamic> response = await _dio.put<dynamic>(
      Endpoints.guarantorInstruments(params.contractId, params.clientId),
      data: <String, dynamic>{
        'types': params.codes,
        if (card != null)
          'card': <String, dynamic>{
            'number': card.number,
            'validity_month': card.month,
            'validity_year': card.year,
            'phone_number': card.phone,
          },
      },
    );

    return GuarantorInstrumentsDto.fromJson(_body(response.data));
  }

  /// Javob `data` qobig'i bilan ham, usiz ham kelishi mumkin.
  static Map<String, dynamic> _body(Object? raw) {
    if (raw is! Map<String, dynamic>) return const <String, dynamic>{};

    final Object? nested = raw['data'];

    return nested is Map<String, dynamic> ? nested : raw;
  }
}
