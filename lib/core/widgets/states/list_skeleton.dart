import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Birinchi yuklashdagi joy egallovchi.
///
/// Nega skelet: bo'sh ekran «ma'lumot yo'q» degan ma'noni berardi.
///
/// Nega `core/` da: uni ikkita ro'yxat ishlatadi (1.2).
final class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 4, this.height});

  final int rows;

  /// Bitta kartaning balandligi. Berilmasa o'rtacha balandlik olinadi.
  final double? height;

  @override
  Widget build(BuildContext context) => Column(
    children: List<Widget>.generate(rows, (int index) => _card()),
  );

  Widget _card() => Container(
    height: height ?? ScreenSize.h120,
    margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r20),
      border: AppSurface.border(),
    ),
  );
}
