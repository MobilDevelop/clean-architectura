import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

class AppVersionWatermark extends StatelessWidget {
  const AppVersionWatermark({super.key, required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    if (version.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      // SafeArea — matn iOS'dagi Dynamic Island/notch tagiga tushib qolmasligi uchun.
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: ScreenSize.h8),
            child: Text( version,style: AppTheme.data.textTheme.displayMedium!.copyWith( fontSize: ScreenSize.sp18,color: AppTheme.colors.black.withValues(alpha: 0.3)),
            ),
          ),
        ),
      ),
    );
  }
}
