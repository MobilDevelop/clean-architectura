import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';

double _percent(Object? raw) => raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '') ?? 0;

final class SpecialTariffDto {
  const SpecialTariffDto(this._json);

  factory SpecialTariffDto.fromJson(Map<String, dynamic> json) => SpecialTariffDto(json);

  final Map<String, dynamic> _json;

  SpecialTariff toEntity() {
    final Object? raw = _json['back_margin'];
    final Map<String, dynamic> back = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

    return SpecialTariff(
      id: _json['id'] as int? ?? 0,
      name: _json['name']?.toString() ?? '',
      frontMargin: _percent(_json['front_margin']),
      prepaymentPercent: _percent(_json['prepayment_percent']),
      quarters: <double>[
        _percent(back['first_quarter']),
        _percent(back['second_quarter']),
        _percent(back['third_quarter']),
        _percent(back['fourth_quarter']),
      ],
      startsAt: _json['starts_at']?.toString() ?? '',
      endsAt: _json['ends_at']?.toString() ?? '',
    );
  }
}
