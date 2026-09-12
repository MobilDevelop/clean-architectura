import 'package:colloborator_v3/core/contract/contract_status.dart';

/// Chiqim tovarlar ekranining matnlari.
abstract final class OutputText {
  static const String title = "Chiqim tovarlar";

  static const String emptyTitle = "Chiqim uchun shartnoma yo'q";
  static const String emptyMessage = "Boshqa sanani tanlab ko'ring";

  static const String products = "Tovarlar";
  static const String noProducts = "Tovar topilmadi";
  static const String count = "dona";

  static const String release = "Chiqim berish";
  static const String returnTitle = "Tovarlarni qaytarish";
  static String returnAction(int count) => count == 0
      ? "Qaytariladigan tovarni belgilang"
      : "$count ta tovarni qaytarish";
  static const String returnConfirm = "Qaytarish";
  static const String returnCancel = "Yo'q";
  static String returnQuestion(int count) =>
      "Belgilangan $count ta tovar shartnomadan qaytariladi. Bu amalni bekor qilib bo'lmaydi.";
  static const String returned = "Tovarlar qaytarildi";

  static const String filter = "Sana bo'yicha filtr";
  static const String filterSubtitle = "Kunni tanlang";

  /// Holat matni **faqat** `ContractStatus` dan hisoblanadi.
  ///
  /// Backend `status` maydonida tayyor matn ham yuboradi, lekin u
  /// ishlatilmaydi: backend matnini foydalanuvchiga chiqarish taqiqlangan
  /// (3.9, 13.4) va u tarjimadan tashqarida qolardi.
  ///
  /// `switch` to'liq qamrab olingan — `_` yo'q. Yangi holat qo'shilsa
  /// kompilyatsiya xato beradi va u "noma'lum" bo'lib jimgina o'tib
  /// ketmaydi (10-bo'lim, O).
  static String status(ContractStatus status) => switch (status) {
    ContractStatus.created => "Yaratilgan",
    ContractStatus.scoring => "Skoringda",
    ContractStatus.failed => "Skoringdan o'tmadi",
    ContractStatus.notAllowed => "Ruxsat berilmagan",
    ContractStatus.rejected => "Rad etilgan",
    ContractStatus.edited => "Tahrirlangan",
    ContractStatus.allowed => "Ruxsat berilgan",
    ContractStatus.faceVerified => "Yuz tasdiqlangan",
    ContractStatus.signed => "Imzolangan",
    ContractStatus.confirmed => "Tasdiqlangan",
    ContractStatus.canceledByClient => "Mijoz bekor qilgan",
    ContractStatus.invoiceCreated => "Faktura yaratilgan",
    ContractStatus.canceled => "Bekor qilingan",
    ContractStatus.waitingSms => "SMS kutilmoqda",
    ContractStatus.errorFound => "Xatolik aniqlangan",
    ContractStatus.invoiceConfirmed => "Faktura tasdiqlangan",
    ContractStatus.incomeSelect => "Daromad tanlanmagan",
    ContractStatus.unknown => "Holat noma'lum",
  };
}
