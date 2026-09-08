import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';

/// `occupation-types/get-all-autocomplete` javobi.
final class OccupationCatalogDto {
  const OccupationCatalogDto(this._json);

  factory OccupationCatalogDto.fromJson(Map<String, dynamic> json) => OccupationCatalogDto(json);

  final Map<String, dynamic> _json;

  OccupationCatalog toEntity() {
    final Object? raw = _json['occupation_types'];
    final List<dynamic> list = raw is List ? raw : const <dynamic>[];

    return OccupationCatalog(
      // `check` — serverning "bu shartnomada kasb turi so'ralsinmi" qarori.
      isRequired: _json['check'] as bool? ?? false,
      items: list
          .whereType<Map<String, dynamic>>()
          .map(
            (Map<String, dynamic> e) =>
                OccupationType(id: e['id'] as int? ?? 0, name: e['name']?.toString() ?? ''),
          )
          .toList(),
    );
  }
}
