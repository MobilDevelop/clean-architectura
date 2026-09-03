import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bitta tekshiruv natijasi: o'tdi yoki o'tmadi.
final class ScoringCheckRow extends StatelessWidget {
  const ScoringCheckRow({super.key, required this.label, required this.isPassed});

  final String label;
  final bool isPassed;

  @override
  Widget build(BuildContext context) {
    final Color color = isPassed ? AppTheme.colors.primary : AppTheme.colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h6),
      child: Row(
        children: <Widget>[
          Icon(isPassed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: ScreenSize.h20),

          Gap(ScreenSize.w10),
          Expanded(
            child: Text(
              label,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
            ),
          ),

          Text(
            isPassed ? "O'tdi" : "O'tmadi",
            style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
