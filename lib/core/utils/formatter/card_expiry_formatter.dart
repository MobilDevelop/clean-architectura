import 'package:flutter/services.dart';

/// Karta muddatini `MM/YY` ko'rinishiga keltiradi.
///
/// **Faqat formatlaydi.** Ilgari bu yerda oy oralig'i, muddatning o'tgani va
/// juda uzoqqa ketgani ham tekshirilib, yaroqsiz bo'lsa kiritish rad etilar
/// va toast chiqarilardi. Uchtasi ham noto'g'ri edi: yordamchi UI ta'sirini
/// bajarmaydi (6.2), kiritish xatosi maydon tagida ko'rinishi kerak (7.5),
/// `DateTime.now()` esa mantiq ichida chaqirilmaydi (9.4). Qoida endi
/// `CardExpiry` da, tekshiruv entitylarning `issueAt` metodida.
final class CardExpiryFormatter extends TextInputFormatter {
  static const int _digits = 4;

  static final RegExp _notDigit = RegExp(r'\D');
  static final RegExp _digit = RegExp(r'\d');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(_notDigit, '');
    if (digits.length > _digits) digits = digits.substring(0, _digits);

    final int cursor = newValue.selection.end.clamp(0, newValue.text.length);
    final int digitsBeforeCursor = newValue.text.substring(0, cursor).replaceAll(_notDigit, '').length;

    final String formatted = digits.length > 2
        ? '${digits.substring(0, 2)}/${digits.substring(2)}'
        : digits;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: _offsetAfter(formatted, digitsBeforeCursor)),
    );
  }

  /// Kursor foydalanuvchi yozgan raqamdan keyin qoladi: `/` qo'shilgani uchun
  /// oddiy siljish joyini adashtiradi.
  static int _offsetAfter(String formatted, int digitsBefore) {
    int seen = 0;

    for (int i = 0; i < formatted.length; i++) {
      if (!_digit.hasMatch(formatted[i])) continue;
      if (seen == digitsBefore) return i;
      seen++;
    }

    return formatted.length;
  }
}
