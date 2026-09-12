import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';

/// Kartani tasdiqlash oynasining matnlari.
abstract final class CardConfirmText {
  static const String title = "SMS tasdiqlash";
  static const String loadFailed = "Ma'lumotni yuklab bo'lmadi";
  static const String retry = "Qayta urinish";

  static const String codeHint = "SMS kod";
  static const String waiting = "Sms kutish vaqti:";
  static const String resend = "Kodni qayta yuborish";
  static const String skipCard = "Plastik karta tekshirilmasin";
  static const String submit = "Tasdiqlash";
  static const String done = "Yuborildi";

  static const String cardTitle = "Karta ma'lumotini kiriting";
  static const String cardNumber = "Karta raqami";
  static const String cardExpiry = "Amal muddati";
  static const String cardPhone = "Telefon raqami";

  static const String mismatchTitle = "OTP kod yuborishda xatolik";
  static const String cancelContract = "Shartnomani bekor qilish";

  /// SMS qaysi raqamga yuborilgani.
  static String sentTo(String phone) => "SMS kod $phone raqamiga yuborildi";

  static String? issue(CardConfirmIssue issue) => switch (issue) {
    CardConfirmIssue.none => null,
    CardConfirmIssue.codeMissing => "SMS kodni kiriting",
    CardConfirmIssue.cardNumberShort => "Karta raqami 16 xonadan iborat",
    CardConfirmIssue.expiryInvalid => "Karta muddati yaroqsiz",
    CardConfirmIssue.phoneShort => "Telefon raqami to'liq emas",
  };
}
