import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Ilovadagi soyalar.
///
/// Nega core'da: soyani login ham, mijozlar ham ishlatadi. Feature ichida
/// qolsa, bir feature ikkinchisini import qilishga majbur bo'ladi (1.3).
abstract final class AppShadow {
  /// Ro'yxatdagi karta soyasi.
  ///
  /// Nega uch qatlam: birinchi ikkisi kartaning chekkasini fondan ajratadi,
  /// uchinchisi "ko'tarilgan" tuyg'usini beradi. Alfa qiymatlari ataylab juda
  /// past — soya ko'rinmasligi, faqat sezilishi kerak.
  static List<BoxShadow> card() => <BoxShadow>[
    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .03),
      blurRadius: ScreenSize.r2,
      spreadRadius: -ScreenSize.r1,
      offset: Offset(0, ScreenSize.h1),
    ),

    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .03),
      blurRadius: ScreenSize.r3,
      offset: Offset(0, ScreenSize.h1),
    ),

    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .03),
      blurRadius: ScreenSize.r16,
      spreadRadius: -ScreenSize.r4,
      offset: Offset(0, ScreenSize.h8),
    ),
  ];

  /// Ekran markazida turadigan katta panel soyasi (login formasi).
  ///
  /// Nega bunchalik cho'zilgan: panel fondan baland turgandek ko'rinishi uchun
  /// soya uzoqqa va yumshoq tarqaladi.
  static List<BoxShadow> raised() => <BoxShadow>[
    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .01),
      blurRadius: ScreenSize.r18,
      offset: Offset(0, ScreenSize.h9),
    ),

    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .01),
      blurRadius: ScreenSize.r35,
      offset: Offset(0, ScreenSize.h35),
    ),

    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .01),
      blurRadius: ScreenSize.r45,
      offset: Offset(0, ScreenSize.h80),
    ),
  ];

  /// Mazmun ustida suzib turadigan element (banner) uchun soya.
  ///
  /// Nega kartanikidan quyuqroq: banner ro'yxat ustida turadi va undan
  /// aniq ajralib turishi kerak.
  static List<BoxShadow> floating() => <BoxShadow>[
    BoxShadow(
      color: AppTheme.colors.black.withValues(alpha: .08),
      blurRadius: ScreenSize.r20,
      spreadRadius: -ScreenSize.r6,
      offset: Offset(0, ScreenSize.h10),
    ),
  ];
}
