import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Sirt qiymatlari: chegara, ajratuvchi chiziq va xiralik kuchi.
///
/// Nega alohida joyda: bu qiymatlar o'nlab widgetda takrorlanadi. Har birida
/// qo'lda yozilsa, ular asta-sekin bir-biridan uzoqlashadi va ilova "yig'ma"
/// ko'rinib qoladi.
abstract final class AppSurface {
  /// Chegara va ajratuvchi chiziqning sukut bo'yicha shaffofligi.
  static const double _lineAlpha = .7;

  /// Suzuvchi panel ostidagi xiralik kuchi.
  static const double blurSigma = 14;

  /// Suzuvchi panel fonining shaffofligi — ostidagi mazmun sezilib tursin.
  static const double panelAlpha = .72;

  /// Ajratuvchi chiziq rangi.
  static Color line({double alpha = _lineAlpha}) => AppTheme.colors.stroke.withValues(alpha: alpha);

  /// Karta va plitkalarning chegarasi.
  static Border border({double alpha = _lineAlpha}) => Border.all(color: line(alpha: alpha));
}
