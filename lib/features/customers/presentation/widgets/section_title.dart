import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

final class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: ScreenSize.w5, bottom: ScreenSize.h10),
        child: Text(
          text,
          style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
        ),
      ),
    );
  }
}
