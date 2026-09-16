import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Tovar kartasidagi IMEI raqamlari.
///
/// Hisob ko'rsatilmaydi: ikki SIM'li telefonda bitta qurilmaga ikkita IMEI
/// to'g'ri keladi, ya'ni ularning soni dona soni emas.
final class ImeiList extends StatelessWidget {
  const ImeiList({super.key, required this.values, required this.chipColor});

  final List<String> values;

  /// Ikkita kartaning foni boshqacha.
  final Color chipColor;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "IMEI",
          style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.textGraySoft),
        ),

        Gap(ScreenSize.h6),
        Wrap(
          spacing: ScreenSize.w6,
          runSpacing: ScreenSize.h4,
          children: values.map(_chip).toList(),
        ),
      ],
    );
  }

  Widget _chip(String value) => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h2),
    decoration: BoxDecoration(
      color: chipColor,
      borderRadius: BorderRadius.circular(ScreenSize.r8),
      border: AppSurface.border(alpha: .5),
    ),
    child: Text(value, style: AppTheme.data.textTheme.bodySmall),
  );
}
