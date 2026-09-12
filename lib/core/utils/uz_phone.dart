/// O'zbekiston telefon raqami haqidagi yagona bilim manbai.
///
/// Nega alohida: operator kodlari ro'yxati ilgari `PhoneFormatter` ichida
/// turardi va formatter uni tekshirib, **toast chiqarardi**. Formatter —
/// yordamchi, UI ta'siri unga tegishli emas (6.2), kiritish xatosi esa
/// maydonning tagida ko'rinishi kerak (7.5). Endi formatter faqat
/// formatlaydi, tekshiruv esa entitylarning `issue` qoidalarida.
abstract final class UzPhone {
  /// `998` + operator kodi (2) + raqam (7).
  static const int digits = 12;

  static const String countryCode = '998';

  /// Amaldagi operator kodlari. Yangisi chiqsa faqat shu ro'yxat o'zgaradi.
  static const List<String> operators = <String>[
    '90', '91', '93', '94', '95', '97', '98', '99',
    '88', '87', '77', '70', '55', '50', '33', '20',
  ];

  /// Raqam to'liq va operator kodi amaldagilardan birimi.
  ///
  /// Kirish — faqat raqamlar (`998901234567`), maska emas.
  static bool isValid(String value) => value.length == digits && hasOperator(value);

  /// Operator kodi tanilganmi. Raqam hali to'liq bo'lmasa ham tekshiriladi —
  /// shuning uchun uzunlik alohida qaraladi.
  static bool hasOperator(String value) {
    if (!value.startsWith(countryCode) || value.length < 5) return false;

    return operators.contains(value.substring(3, 5));
  }
}
