import 'package:flutter/widgets.dart';


/// Yon menyuning matnlari.
///
/// Nega `core/` da: menyuni ikkita ekran ochadi (mijozlar va shartnomalar),
/// ya'ni u featurega tegishli emas (1.2).
abstract final class DrawerText {
  static const String analysis = "Mijoz tahlili";
  static const String calculator = "Kredit kalkulyator";
  static const String password = "Parolni o'zgartirish";
  static const String support = "Yordam";

  static const String logout = "Akkauntdan chiqish";
  static const String logoutTitle = "Chiqishni tasdiqlang";
  static const String logoutMessage = "Tizimdan chiqasiz. Davom etish uchun qaytadan kirish kerak";
  static const String logoutAction = "Chiqish";

  /// Ekran hali yozilmagan bo'limlar shu belgi bilan turadi.
  ///
  /// Nega belgi, faqat toast emas: bosilgandan **keyin** «ulanmagan» deyish
  /// foydalanuvchini bekorga bosishga majbur qiladi. Belgi buni oldindan
  /// aytadi, toast esa bosish jimgina yo'qolmasligi uchun qoladi (5.8).
  static const String soon = "tez orada";

  static String notReady(String title) => "$title hali ulanmagan";

  static String version(String value) => "Versiya $value";

  /// Ism-familiyadan bosh harflar: «Abdurahmonov Abdulaziz» → «AA».
  static String initials(String fullName) {
    final List<String> parts = fullName
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();

    return "${parts[0].characters.first}${parts[1].characters.first}".toUpperCase();
  }
}
