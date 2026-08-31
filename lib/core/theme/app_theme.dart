import 'package:colloborator_v3/core/theme/base_colors.dart';
import 'package:colloborator_v3/core/theme/dark_mode_color.dart';
import 'package:colloborator_v3/core/theme/light_mode_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static late BaseColors colors;
  static late ThemeMode themeMode;
  static late ThemeData data;

  static Future<void> init() async {
    themeMode = ThemeMode.light;
    colors = getThemeColors(themeMode);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 18.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontSize: 18.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: TextStyle(
        fontSize: 18.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      headlineLarge: TextStyle(
        fontSize: 15.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontSize: 15.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        fontSize: 15.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        fontSize: 14.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      bodyLarge: TextStyle(
        fontSize: 12.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(
        fontSize: 12.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        fontSize: 10.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        fontSize: 10.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
    );

    data = ThemeData(
      fontFamily: 'BetaniaPatmos-Regular',
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      brightness: themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
      textSelectionTheme: TextSelectionThemeData(cursorColor: colors.primary),
      toggleButtonsTheme: ToggleButtonsThemeData(
        selectedColor: colors.primary,
        selectedBorderColor: colors.primary,
        fillColor: colors.primary,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primary,
        activeTickMarkColor: colors.primary,
        thumbColor: colors.primary,
        inactiveTrackColor: colors.primary.withValues(alpha: .25),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colors.background,
        focusColor: colors.primary,
        filled: true,
        errorMaxLines: 3,
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: colors.primary,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 16.sp,
          color: colors.textBlack,
        ),
        counterStyle: textTheme.bodySmall?.copyWith(color: colors.primary),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.red),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.stroke),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: colors.red),
        ),
        helperStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textBlack),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.red),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      ),
    );
  }

  static BaseColors getThemeColors(ThemeMode mode) => mode == ThemeMode.light ? const LightModeColors() : const DarkModeColor();
}
