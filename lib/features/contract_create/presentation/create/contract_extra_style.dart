import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:flutter/material.dart';

/// Qo'shimcha ekranlarning ekrandagi ko'rinishi: nomi, izohi, ikonkasi va rangi.
///
/// Nega rang shu yerda: rang bezak emas, **belgi**. Beshta qator bir xil
/// kulrang bo'lsa, foydalanuvchi ularni faqat o'qib ajratadi. Rang bilan
/// jadval — ko'k, aksiya — sariq, muammo — qizil bo'lib, ular bir qarashda
/// tanib olinadi. Domain rang ham, matn ham yaratmaydi (3.9).
abstract final class ContractExtraStyle {
  static String title(ContractExtra extra) => switch (extra) {
    ContractExtra.schedule => "To'lov jadvali",
    ContractExtra.tariff => "Maxsus tarif",
    ContractExtra.underwriter => "Anderrayter hujjatlari",
    ContractExtra.bonus => "Filial rahbari bonusi",
    ContractExtra.katmSkip => "KATM/MIB tekshiruvi",
  };

  static String hint(ContractExtra extra) => switch (extra) {
    ContractExtra.schedule => "Oylik to'lovni ko'rish",
    ContractExtra.tariff => "Aksiya shartlarini biriktirish",
    ContractExtra.underwriter => "Daromad hujjatlarini yuklash",
    ContractExtra.bonus => "Tasdiqlash yoki rad etish",
    ContractExtra.katmSkip => "Tekshiruvni o'tkazib yuborish",
  };

  static IconData icon(ContractExtra extra) => switch (extra) {
    ContractExtra.schedule => Icons.calendar_month_outlined,
    ContractExtra.tariff => Icons.local_offer_outlined,
    ContractExtra.underwriter => Icons.fact_check_outlined,
    ContractExtra.bonus => Icons.card_giftcard_outlined,
    ContractExtra.katmSkip => Icons.gpp_maybe_outlined,
  };

  /// Rang ma'noni bildiradi: pul — yashil, ma'lumot — ko'k, aksiya — sariq,
  /// hal qilinishi kerak bo'lgan muammo — qizil.
  static Color color(ContractExtra extra) => switch (extra) {
    ContractExtra.schedule => AppTheme.colors.blue,
    ContractExtra.tariff => AppTheme.colors.yellow,
    ContractExtra.underwriter => AppTheme.colors.secondary,
    ContractExtra.bonus => AppTheme.colors.primary,
    ContractExtra.katmSkip => AppTheme.colors.red,
  };

  /// Nega hozircha ochib bo'lmaydi.
  static String? block(ContractExtraBlock block) => switch (block) {
    ContractExtraBlock.none => null,
    ContractExtraBlock.noContract => "Avval tovar qo'shing",
    ContractExtraBlock.noProducts => "Avval tovar qo'shing",
    ContractExtraBlock.noPaymentDay => "Avval to'lov kunini tanlang",
  };
}
