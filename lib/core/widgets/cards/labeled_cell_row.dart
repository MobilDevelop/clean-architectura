import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Kartadagi bitta «yorliq — qiymat» yacheykasi.
final class LabeledCell {
  const LabeledCell({required this.label, required this.value});

  final String label;
  final Widget value;
}

final class LabeledCellRow extends StatelessWidget {
  const LabeledCellRow({super.key, required this.cells, this.isLast = false});

  /// Bitta yoki ikkita.
  final List<LabeledCell> cells;

  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(height: ScreenSize.h20, thickness: ScreenSize.h1, color: AppSurface.line()),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (final (int index, LabeledCell cell) in cells.indexed) ...<Widget>[
              if (index > 0) Gap(ScreenSize.w10),
              Expanded(child: _cell(cell, isEnd: index > 0)),
            ],
          ],
        ),

        if (isLast) Gap(ScreenSize.h2),
      ],
    );
  }

  Widget _cell(LabeledCell cell, {required bool isEnd}) => Column(
    crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        cell.label,
        textAlign: isEnd ? TextAlign.right : TextAlign.left,
        style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey),
      ),

      Gap(ScreenSize.h2),
      cell.value,
    ],
  );
}
