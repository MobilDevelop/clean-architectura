import 'package:colloborator_v3/core/utils/json_value.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';

Map<String, dynamic> _object(Object? raw) => raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

/// Kengaytirilgan tahlilda tekshirilgan karta. Bo'sh obyekt — karta bilan
/// tekshirilmagan, bu meʼyoriy holat.
final class AnalysisCardDto {
  const AnalysisCardDto(this._json);

  factory AnalysisCardDto.fromJson(Map<String, dynamic> json) => AnalysisCardDto(json);

  final Map<String, dynamic> _json;

  AnalysisCard toEntity() => AnalysisCard(
    id: _json['id'] as int? ?? 0,
    number: JsonValue.toDigits(_json['card_number']),
    expiry: _json['validity_month'] != null && _json['validity_year'] != null
        ? '${_json['validity_month'].toString().padLeft(2, '0')}/${_json['validity_year'].toString().padLeft(2, '0')}'
        : '',
  );
}

/// `GET prescoring` javobidagi bitta yozuv.
final class CustomerAnalysisDto {
  const CustomerAnalysisDto(this._json);

  factory CustomerAnalysisDto.fromJson(Map<String, dynamic> json) => CustomerAnalysisDto(json);

  final Map<String, dynamic> _json;

  /// `id` SMS tasdiqlashda `pre_scoring_id` bo'lib ketadi — yo'qolsa
  /// tasdiqlash boshqa so'rovga tegishli bo'lib qolishi mumkin (4.6).
  CustomerAnalysis toEntity() => CustomerAnalysis(
    id: JsonValue.requireInt(_json['id'], field: 'analysis.id'),
    fullName: _json['fio'] as String? ?? '',
    inps: _json['inps'] as String? ?? '',
    status: AnalysisStatus.fromCode(_json['status'] as String? ?? ''),
    createdAt: _json['created_at'] as String? ?? '',
    elmaApplicationId: _json['elma_application_id']?.toString() ?? '',
    elmaInstanceId: _json['elma_instanceid']?.toString() ?? '',
    freeLimit: JsonValue.toInt(_json['free_limit']),
    phone: JsonValue.toDigits(_json['phone_number']),
    card: AnalysisCardDto.fromJson(_object(_json['card'])).toEntity(),
  );
}
