import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Ro'yxat ustidagi sarlavha va topilgan elementlar soni.
final class ResultsHeader extends StatelessWidget {
  const ResultsHeader({super.key, required this.count, this.title = "Natijalar"});

  final int count;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h8, ScreenSize.h16, ScreenSize.h10),
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
          ),

          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              borderRadius: BorderRadius.circular(ScreenSize.r15),
              border: AppSurface.border(),
            ),
            child: Text("$count ta", style: AppTheme.data.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
