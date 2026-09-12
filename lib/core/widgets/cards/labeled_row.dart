import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Kartadagi «yorliq — qiymat» qatori. Oxirgisidan keyin chiziq chizilmaydi.
///
/// Nega `core/` da: shartnoma va faktura kartalari bir xil jadval ko'rinishida
/// (1.2), va matn sig'ish qoidasi bitta joyda turishi kerak.
final class LabeledRow extends StatelessWidget {
  const LabeledRow({super.key, required this.label, required this.value, this.isLast = false});

  final String label;
  final Widget value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(height: ScreenSize.h20, thickness: ScreenSize.h1, color: AppSurface.line()),

        // Yorliq va qiymat bir qatorga sig'sa — chetlarga tarqaladi; sig'masa
        // qiymat o'z qatoriga tushadi. `Row` da ulardan biri baribir
        // kesilardi: 360px ekranda tizim shrifti 1.2× bo'lganda uzun holat
        // nomi uch nuqta bilan tugab, o'qib bo'lmay qolardi.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: ScreenSize.w10,
          runSpacing: ScreenSize.h6,
          children: <Widget>[
            Text(label, style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey)),

            value,
          ],
        ),

        if (isLast) Gap(ScreenSize.h2),
      ],
    );
  }
}
