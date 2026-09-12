/// Karta amal qilish muddati haqidagi yagona qoida.
///
/// Nega alohida: bu tekshiruv ilgari faqat `CardExpiryFormatter` ichida
/// turardi va u yerda `DateTime.now()` chaqirilardi — ya'ni qoida testda
/// almashtirib bo'lmaydigan soatga bog'langan (9.4), yaroqsiz muddat esa
/// toast bilan aytilardi (6.2, 7.5). Endi qoida sof Dart, vaqt esa
/// tashqaridan beriladi.
abstract final class CardExpiry {
  /// Karta bugungidan shuncha yil oldinga amal qilishi mumkin.
  static const int maxYears = 5;

  /// Oy 1–12 oralig'idami, muddati o'tmaganmi va juda uzoqqa ketmaganmi.
  ///
  /// `month` va `year` chaqiruvchidan keladi: ikkita entity muddatni ikki xil
  /// shaklda saqlaydi (`MMYY` va `MM/YY`), ajratish ularning ishi.
  static bool isUsable({required int month, required int year, required DateTime now}) {
    if (month < 1 || month > 12) return false;

    final int currentYear = now.year % 100;
    final int maxYear = currentYear + maxYears;

    if (year < currentYear || (year == currentYear && month < now.month)) return false;
    if (year > maxYear || (year == maxYear && month > now.month)) return false;

    return true;
  }
}
