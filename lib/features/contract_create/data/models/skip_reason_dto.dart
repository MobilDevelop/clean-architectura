import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';

final class SkipReasonDto {
  const SkipReasonDto(this._json);

  factory SkipReasonDto.fromJson(Map<String, dynamic> json) => SkipReasonDto(json);

  final Map<String, dynamic> _json;

  SkipReason toEntity() => SkipReason(id: _json['id'] as int? ?? 0, name: _json['name']?.toString() ?? '');
}
