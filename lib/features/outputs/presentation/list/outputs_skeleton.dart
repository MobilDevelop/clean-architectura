import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Birinchi yuklashdagi joy egallovchi.
///
/// Nega skelet: bo'sh ekran «ma'lumot yo'q» degan ma'noni berardi.
final class OutputsSkeleton extends StatelessWidget {
  const OutputsSkeleton({super.key});

  static const int _rows = 4;

  @override
  Widget build(BuildContext context) => Column(
    children: List<Widget>.generate(_rows, (int index) => _card()),
  );

  Widget _card() => Container(
    height: ScreenSize.h120,
    margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r20),
      border: AppSurface.border(),
    ),
  );
}
