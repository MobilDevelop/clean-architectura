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

    // Shkala Figma'dan olingan (`Ishonch Сollaborator - app` → Cover →
    // Typography, va uchta tayyor ekrandagi haqiqiy ishlatilish).
    //
    // Dizayndagi o'lchamlar: 24 / 20 / 16 / 15 / 14 / 13. Ilgari bu yerda
    // 18 / 15 / 14 / 12 / 10 turardi — ya'ni butun ilova dizayndan 1–3px
    // kichik chizilardi.
    //
    // Og'irliklar ham to'g'rilandi: dizayn urg'u uchun **600** ni ishlatadi
    // (uchta ekranda 26 marta), 700 esa faqat sahifa sarlavhalarida. Mavzuda
    // 600 umuman yo'q edi va 500 dan to'g'ri 700 ga sakrardi.
    //
    // Qator balandligi dizayn nisbatlariga ko'ra: ≥20px da 1.4, ≤18px da 1.5.
    // Ilgari u umuman berilmagan va shriftning o'z qiymati ishlatilardi.
    final textTheme = TextTheme(
      // Dialog sarlavhalari va yirik raqamlar — 24.
      displayLarge: TextStyle(
        fontSize: 20.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        fontSize: 20.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w600,
      ),
      displaySmall: TextStyle(
        fontSize: 20.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      // Karta sarlavhasi, mijoz ismi — 16.
      headlineLarge: TextStyle(
        fontSize: 16.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        fontSize: 16.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      headlineSmall: TextStyle(
        fontSize: 16.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      // Bo'lim sarlavhasi va amal matni — 15.
      titleLarge: TextStyle(
        fontSize: 15.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontSize: 15.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        fontSize: 15.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      // Asosiy matn — 14.
      bodyLarge: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontSize: 14.sp,
        height: 1.5,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
      // Izoh va pastki navigatsiya — 13.
      labelLarge: TextStyle(
        fontSize: 13.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        fontSize: 13.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(
        fontSize: 13.sp,
        height: 1.4,
        color: AppTheme.colors.textGraySoft,
        fontWeight: FontWeight.w400,
      ),
    );

    data = ThemeData(
      // Oila `pubspec.yaml` dagi `fonts:` bo'limida e'lon qilingan nom bilan
      // yoziladi. Ilgari bu yerda `BetaniaPatmos-Regular` turardi — u oila
      // sifatida umuman e'lon qilinmagan, shuning uchun Flutter uni topa
      // olmay tizim shriftiga tushib ketardi va ilova Figma shriftida ham,
      // NotoSans'da ham chizilmasdi.
      fontFamily: 'NotoSans',
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
