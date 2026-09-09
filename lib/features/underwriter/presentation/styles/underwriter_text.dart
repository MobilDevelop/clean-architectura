import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:flutter/material.dart';

/// Bo'limlarning ekrandagi ko'rinishi va xato matnlari.
///
/// Domain na matn, na rang yaratadi (3.9) — u faqat enum qaytaradi.
abstract final class UnderwriterText {
  /// Ma'lumotnoma bo'sh chiqqanda oynada turadigan sabab.
  ///
  /// Bu nuqtada ro'yxat allaqachon so'ralgan: bo'sh bo'lishi serverda hech
  /// nima yo'qligini emas, so'rov natija bermaganini bildiradi.
  static const String referenceEmpty = "Ro'yxat yuklanmadi. Ekranni qayta oching";

  /// Brend tanlangan, lekin unga marka biriktirilmagan — bu qonuniy holat.
  static const String modelsEmpty = "Bu brend uchun marka topilmadi";

  static String title(UnderwriterKind kind) => switch (kind) {
    UnderwriterKind.salary => "Ish haqi",
    UnderwriterKind.pension => "Pensiya",
    UnderwriterKind.military => "Guvohnoma",
    UnderwriterKind.student => "Talaba",
    UnderwriterKind.car => "Avtomobil",
  };

  static String documentTitle(UnderwriterKind kind) => switch (kind) {
    UnderwriterKind.salary => "Ish haqi ma'lumoti",
    UnderwriterKind.pension => "Pensiya ma'lumoti",
    UnderwriterKind.military => "Guvohnoma",
    UnderwriterKind.student => "Talaba guvohnomasi",
    UnderwriterKind.car => "Avtomobil pasporti",
  };

  static IconData icon(UnderwriterKind kind) => switch (kind) {
    UnderwriterKind.salary => Icons.payments_outlined,
    UnderwriterKind.pension => Icons.elderly_outlined,
    UnderwriterKind.military => Icons.military_tech_outlined,
    UnderwriterKind.student => Icons.school_outlined,
    UnderwriterKind.car => Icons.directions_car_outlined,
  };

  static Color color(UnderwriterKind kind) => switch (kind) {
    UnderwriterKind.salary => AppTheme.colors.primary,
    UnderwriterKind.pension => AppTheme.colors.blue,
    UnderwriterKind.military => AppTheme.colors.yellow,
    UnderwriterKind.student => AppTheme.colors.secondary,
    UnderwriterKind.car => AppTheme.colors.blue,
  };

  /// Saqlashga to'sqinlik qilayotgan kamchilik.
  static String? issue(UnderwriterIssue issue) => switch (issue) {
    UnderwriterIssue.none => null,
    UnderwriterIssue.noFiles => "Kamida bitta hujjat yuklang",
    UnderwriterIssue.amountMissing => "Summani kiriting",
    UnderwriterIssue.positionMissing => "Lavozimni tanlang",
    UnderwriterIssue.brandMissing => "Avtomobil brendini tanlang",
    UnderwriterIssue.modelMissing => "Avtomobil markasini tanlang",
    UnderwriterIssue.yearMissing => "Ishlab chiqarilgan yilni tanlang",
  };

  /// Fayl qo'shib bo'lmaganining sababi.
  static String? file(FileIssue issue) => switch (issue) {
    FileIssue.none => null,
    FileIssue.tooMany => "Ko'pi bilan ${UnderwriterFileRule.maxCount} ta hujjat yuklanadi",
    FileIssue.tooLarge => "Fayl hajmi 2 MB dan kichik bo'lishi kerak",
    FileIssue.wrongType => "Faqat PDF, JPG va PNG qabul qilinadi",
  };

  static const List<String> _months = <String>[
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];

  /// `2026, 8` → `Avgust 2026`.
  static String month(int year, int month) =>
      month < 1 || month > 12 ? "$year" : "${_months[month - 1]} $year";
}
