import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Kamerada nima qilish kerakligini aytadigan qator.
final class FaceGuidanceBar extends StatelessWidget {
  const FaceGuidanceBar({super.key, required this.message, required this.isReady});

  final String message;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: ScreenSize.h56),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h10),
      decoration: BoxDecoration(
        color: isReady ? AppTheme.colors.primary.withValues(alpha: .12) : AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: isReady ? Border.all(color: AppTheme.colors.primary.withValues(alpha: .35)) : AppSurface.border(),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.data.textTheme.titleLarge?.copyWith(
          color: isReady ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
        ),
      ),
    );
  }
}
