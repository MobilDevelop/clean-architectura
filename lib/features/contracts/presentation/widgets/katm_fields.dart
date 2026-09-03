import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/katm_labels.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// Nom-qiymat juftliklari ro'yxati.
///
/// Kodlar (`"000"`, `"01180"`) songa aylantirilmaydi — faqat summa deb
/// belgilangan maydonlar formatlanadi. Tiyin → so'm o'girish DTO'da bajarilgan.
final class KatmFields extends StatelessWidget {
  const KatmFields({super.key, required this.row, required this.labels});

  final KatmRow row;
  final Map<String, String> labels;

  static String display(KatmField field) {
    if (!field.isMoney) return KatmLabels.translate(field.value);

    final num? value = num.tryParse(field.value);

    return value == null ? field.value : "${_sumFormat.format(value)} so'm";
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, String>> rows = labels.entries.where(_isVisible).toList();

    if (rows.isEmpty) {
      return Text("Ma'lumot yo'q", style: AppTheme.data.textTheme.bodyMedium);
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < rows.length; i++) ...<Widget>[
          if (i > 0) Divider(height: 1, color: AppSurface.line(alpha: .5)),
          _row(rows[i].value, row.field(rows[i].key)),
        ],
      ],
    );
  }

  /// Muammoli summalar sog'lom shartnomada nol bo'ladi — bo'sh qator qoldirmaslik
  /// uchun chizilmaydi.
  bool _isVisible(MapEntry<String, String> label) {
    final String value = row.valueOf(label.key);
    if (value.isEmpty) return false;

    if (!KatmLabels.hideWhenZero.contains(label.key)) return true;

    return (num.tryParse(value) ?? 0) != 0;
  }

  Widget _row(String title, KatmField? field) => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 5, child: Text(title, style: AppTheme.data.textTheme.bodySmall)),

        Gap(ScreenSize.w8),
        Expanded(
          flex: 4,
          child: Text(
            field == null ? '' : display(field),
            textAlign: TextAlign.end,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(
              color: AppTheme.colors.blackSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
