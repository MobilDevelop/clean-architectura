import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/katm_money_fields.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';

/// KATM javobi og'ir (1.7 MB gacha) va jadval bo'limlaridagi maydonlar soni
/// bo'limga qarab o'zgaradi. Shuning uchun qatorlar tiplangan ro'yxatga
/// aylantiriladi, `Map` esa data qatlamidan chiqmaydi.
final class KatmReportDto {
  const KatmReportDto(this._json);

  final Map<String, dynamic> _json;

  /// Skalyar maydonlar qatorga, ichki massivlar esa alohida ro'yxatga tushadi.
  /// Ilgari ular tashlab yuborilardi va tafsilot oynasi bo'sh qolardi.
  static KatmRow _row(Map<String, dynamic> json) {
    final List<KatmField> fields = <KatmField>[];
    final List<KatmNested> nested = <KatmNested>[];

    for (final MapEntry<String, dynamic> entry in json.entries) {
      final Object? value = entry.value;

      if (value is List) {
        final List<Map<String, dynamic>> rows = value.whereType<Map<String, dynamic>>().toList();
        if (rows.isNotEmpty) nested.add(KatmNested(key: entry.key, rows: rows.map(_row).toList()));
        continue;
      }

      if (value is Map) continue;

      fields.add(
        KatmField(key: entry.key, value: value?.toString() ?? '', isMoney: KatmMoneyFields.isMoney(entry.key)),
      );
    }

    return KatmRow(fields, nested: nested);
  }

  static List<Map<String, dynamic>> _list(Object? raw) =>
      raw is List ? raw.whereType<Map<String, dynamic>>().toList() : const <Map<String, dynamic>>[];

  KatmReport toEntity() {
    final Map<String, dynamic> scoring = _json['scoring'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final Map<String, dynamic> scale = scoring['scale'] as Map<String, dynamic>? ?? const <String, dynamic>{};
    final Map<String, dynamic> ban = _json['credit_ban'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    final List<KatmSection> layout = _list(_json['layout'])
        .map(
          (Map<String, dynamic> e) => KatmSection(
            key: e['key'] as String? ?? '',
            title: e['title'] as String? ?? '',
          ),
        )
        .toList();

    return KatmReport(
      state: reportStateFrom(_json['state'] as String?),
      title: _json['title'] as String? ?? '',
      meta: _meta(),
      subject: _row(_json['subject'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
      scoring: KatmScoring(
        grade: scoring['grade'] as int? ?? 0,
        className: scoring['class'] as String? ?? '',
        level: scoring['level'] as String? ?? '',
        // Shkala kelmasa `min == max` bo'ladi va gauge chizilmaydi.
        min: scale['min'] as int? ?? 0,
        max: scale['max'] as int? ?? 0,
        bands: _list(scale['bands'])
            .map(
              (Map<String, dynamic> e) => KatmBand(
                name: e['class'] as String? ?? '',
                from: e['from'] as int? ?? 0,
                to: e['to'] as int? ?? 0,
              ),
            )
            .toList(),
      ),
      dynamics: _list(_json['dynamics'])
          .map(
            (Map<String, dynamic> e) =>
                KatmDynamic(period: e['period'] as String? ?? '', score: e['score'] as int? ?? 0),
          )
          .toList(),
      overview: _row(_json['overview'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
      hasCreditBan: ban['banned'] as bool? ?? false,
      isBlacklisted: _json['blacklisted'] as bool? ?? false,
      layout: layout,
      tables: layout.map((KatmSection section) => _table(section.key)).toList(),
      comments: _list(_json['comments'])
          .map(
            (Map<String, dynamic> e) =>
                KatmComment(order: e['rn'] as int? ?? 0, content: e['content'] as String? ?? ''),
          )
          .toList(),
      scoredAt: _json['scored_at'] as String? ?? '',
    );
  }

  KatmMeta _meta() {
    final Map<String, dynamic> meta = _json['meta'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return KatmMeta(
      reportName: meta['report_name'] as String? ?? '',
      claimId: meta['claim_id'] as String? ?? '',
      claimDate: meta['claim_date'] as String? ?? '',
      orgName: meta['org_name'] as String? ?? '',
      subjectType: meta['subject_type'] as String? ?? '',
    );
  }

  /// `open_contracts` obyekt bo'lib keladi (`items` + `totals`), qolgan
  /// bo'limlar to'g'ridan-to'g'ri massiv.
  KatmTable _table(String key) {
    final Object? data = _json[key];

    if (data is Map<String, dynamic>) {
      final Map<String, dynamic> totals = data['totals'] as Map<String, dynamic>? ?? const <String, dynamic>{};

      return KatmTable(
        key: key,
        rows: _list(data['items']).map(_row).toList(),
        totals: totals.isEmpty ? null : _row(totals),
      );
    }

    return KatmTable(key: key, rows: _list(data).map(_row).toList(), totals: null);
  }
}
