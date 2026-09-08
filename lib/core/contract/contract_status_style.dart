import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_status.dart';
import 'package:flutter/material.dart';

/// Status holatini ekranda qanday ko'rsatish.
///
/// Nega presentationda: matn ham, rang ham foydalanuvchiga ko'rinadigan narsa.
/// Domain faqat holatning o'zini biladi (3.9).
abstract final class ContractStatusStyle {
  static String label(ContractStatus status) => switch (status) {
    ContractStatus.created => "Yaratilgan",
    ContractStatus.scoring => "Skoring jarayonida",
    ContractStatus.failed => "Muvaffaqiyatsiz",
    ContractStatus.notAllowed => "Ruxsat etilmadi",
    ContractStatus.rejected => "Rad etilgan",
    ContractStatus.edited => "Tahrirlangan",
    ContractStatus.allowed => "Ruxsat etildi",
    ContractStatus.faceVerified => "Mijoz yuzi tasdiqlangan",
    ContractStatus.signed => "Imzolangan",
    ContractStatus.confirmed => "Shartnoma tasdiqlangan",
    ContractStatus.canceledByClient => "Mijoz bekor qilgan",
    ContractStatus.invoiceCreated => "Faktura yaratilgan",
    ContractStatus.canceled => "Bekor qilingan",
    ContractStatus.waitingSms => "SMS kodi kutilmoqda",
    ContractStatus.errorFound => "Xatolik aniqlandi",
    ContractStatus.invoiceConfirmed => "Faktura tasdiqlandi",
    ContractStatus.incomeSelect => "Daromad tanlash",
    ContractStatus.unknown => "Holat noma'lum",
  };

  /// Nega uch guruh: foydalanuvchi uchun holatlar "yakunlandi", "davom etmoqda"
  /// va "to'xtadi" degan uch xabarni beradi. O'n yetti rang emas.
  static Color color(ContractStatus status) => switch (status) {
    ContractStatus.created ||
    ContractStatus.allowed ||
    ContractStatus.faceVerified ||
    ContractStatus.signed ||
    ContractStatus.confirmed ||
    ContractStatus.invoiceConfirmed => AppTheme.colors.primary,

    ContractStatus.scoring ||
    ContractStatus.invoiceCreated ||
    ContractStatus.waitingSms ||
    ContractStatus.incomeSelect ||
    ContractStatus.edited => AppTheme.colors.blue,

    ContractStatus.failed ||
    ContractStatus.rejected ||
    ContractStatus.canceled ||
    ContractStatus.canceledByClient => AppTheme.colors.red,

    ContractStatus.notAllowed ||
    ContractStatus.errorFound => AppTheme.colors.yellow,

    ContractStatus.unknown => AppTheme.colors.grey,
  };
}
