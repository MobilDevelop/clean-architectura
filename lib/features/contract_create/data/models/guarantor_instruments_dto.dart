import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';

final class GuarantorInstrumentsDto {
  const GuarantorInstrumentsDto(this._json);

  factory GuarantorInstrumentsDto.fromJson(Map<String, dynamic> json) => GuarantorInstrumentsDto(json);

  final Map<String, dynamic> _json;

  GuarantorInstruments toEntity() {
    final List<String> codes = _codes(_json['types']);

    return GuarantorInstruments(
      types: codes.map(InstrumentType.fromCode).nonNulls.toSet(),
      unknown: codes.where((String code) => InstrumentType.fromCode(code) == null).toSet(),
      card: _card(_json['p2p']),
      exclusive: _exclusive(_json['rules']),
    );
  }

  static List<String> _codes(Object? raw) =>
      raw is List ? raw.map((Object? e) => e.toString()).toList() : const <String>[];

  static InstrumentCardInfo? _card(Object? raw) {
    if (raw is! Map) return null;

    return InstrumentCardInfo(
      mask: raw['card_number_mask'] as String? ?? '',
      expire: raw['expire'] as String? ?? '',
      phone: raw['phone_number'] as String? ?? '',
    );
  }

  /// Qoida serverdan keladi. Ilova tanimagan tur juftlikda bo'lsa, o'sha
  /// juftlik tashlab yuboriladi — u holda taqiqni backend `409` bilan aytadi.
  static Set<Set<InstrumentType>> _exclusive(Object? raw) {
    if (raw is! Map || raw['mutually_exclusive'] is! List) return const <Set<InstrumentType>>{};

    final Set<Set<InstrumentType>> pairs = <Set<InstrumentType>>{};

    for (final Object? pair in raw['mutually_exclusive'] as List) {
      if (pair is! List) continue;

      final Set<InstrumentType> types = pair
          .map((Object? e) => InstrumentType.fromCode(e.toString()))
          .nonNulls
          .toSet();

      if (types.length > 1) pairs.add(types);
    }

    return pairs;
  }
}
