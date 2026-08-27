import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Kichik yorliq — masalan pasport turi.
final class CustomerChip extends StatelessWidget {
  const CustomerChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h3),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .22)),
      ),
      child: Text(
        label,
        style: AppTheme.data.textTheme.labelMedium?.copyWith(color: AppTheme.colors.primary),
      ),
    );
  }
}
