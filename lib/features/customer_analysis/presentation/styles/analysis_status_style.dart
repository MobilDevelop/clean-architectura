import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:flutter/material.dart';

/// Status holatini ekranda qanday ko'rsatish. Matn ham, rang ham
/// foydalanuvchiga ko'rinadigan narsa — domain faqat holatning o'zini
/// biladi (3.9).
abstract final class AnalysisStatusStyle {
  static String label(AnalysisStatus status) => switch (status) {
    AnalysisStatus.created => "Yaratildi",
    AnalysisStatus.inProgress => "Jarayonda",
    AnalysisStatus.cancelled => "Bekor qilindi",
    AnalysisStatus.edited => "Tahrirlandi",
    AnalysisStatus.confirmed => "Tasdiqlandi",
    AnalysisStatus.rejected => "Rad etildi",
    AnalysisStatus.failed => "Muvaffaqiyatsiz",
    AnalysisStatus.waitSmsCode => "SMS kod kutilmoqda",
    AnalysisStatus.resendSmsCode => "SMS kod qayta yuborildi",
    AnalysisStatus.unknown => "Noma'lum",
  };

  static Color color(AnalysisStatus status) => switch (status) {
    AnalysisStatus.created => AppTheme.colors.primary,
    AnalysisStatus.inProgress || AnalysisStatus.resendSmsCode || AnalysisStatus.waitSmsCode =>
      AppTheme.colors.blue,
    AnalysisStatus.cancelled || AnalysisStatus.rejected || AnalysisStatus.failed => AppTheme.colors.red,
    AnalysisStatus.edited => AppTheme.colors.black,
    AnalysisStatus.confirmed => AppTheme.colors.green,
    AnalysisStatus.unknown => AppTheme.colors.grey,
  };
}
