import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
final class LabeledRow extends StatelessWidget {
  const LabeledRow({super.key, required this.label, required this.value, this.isLast = false});

  final String label;
  final Widget value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: ScreenSize.h20, thickness: ScreenSize.h1, color: AppSurface.line()),

        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: ScreenSize.w10,
          runSpacing: ScreenSize.h4,
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
