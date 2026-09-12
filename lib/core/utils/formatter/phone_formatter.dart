import 'package:colloborator_v3/core/utils/uz_phone.dart';
import 'package:flutter/services.dart';

/// Telefon raqamini ko'rsatish shakliga keltiradi: `998901234567` →
/// `+998 90 123-45-67`.
///
/// **Faqat formatlaydi.** Ilgari bu yerda operator kodi ham tekshirilib,
/// yaroqsiz bo'lsa kiritish rad etilar va toast chiqarilardi. Ikkalasi ham
/// noto'g'ri edi: yordamchi UI ta'sirini bajarmaydi (6.2), kiritish xatosi
/// esa maydonning tagida ko'rinishi kerak (7.5) — endi u entitylarning
/// `issue` qoidalaridan keladi (`UzPhone.isValid`).
final class PhoneFormatter extends TextInputFormatter {
  /// Tayyor raqamni ko'rsatish shakliga keltiradi. Kiritish paytida emas —
  /// mavjud qiymatni maydonga qo'yishda ishlatiladi.
  static String mask(String value) => _format(_normalized(value));

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final int cursor = newValue.selection.end.clamp(0, newValue.text.length);
    final int typedBeforeCursor = newValue.text.substring(0, cursor).replaceAll(_notDigit, '').length;

    final String raw = newValue.text.replaceAll(_notDigit, '');
    final bool prepended = !raw.startsWith('99');
    final String digits = _normalized(newValue.text);

    final String formatted = _format(digits);
    final int digitsBeforeCursor = prepended ? typedBeforeCursor + 3 : typedBeforeCursor;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: _offsetAfter(formatted, digitsBeforeCursor)),
    );
  }

  static final RegExp _notDigit = RegExp(r'\D');
  static final RegExp _digit = RegExp(r'\d');

  /// Mamlakat kodi qo'shiladi va uzunlik chegaralanadi.
  static String _normalized(String value) {
    String digits = value.replaceAll(_notDigit, '');
    if (digits.isEmpty) return '';

    if (!digits.startsWith(UzPhone.countryCode)) digits = '${UzPhone.countryCode}$digits';

    return digits.length > UzPhone.digits ? digits.substring(0, UzPhone.digits) : digits;
  }

  static String _format(String digits) {
    if (digits.isEmpty) return '';

    final StringBuffer result = StringBuffer('+${UzPhone.countryCode}');
    if (digits.length > 3) result.write(' ${digits.substring(3, digits.length.clamp(3, 5))}');
    if (digits.length > 5) result.write(' ${digits.substring(5, digits.length.clamp(5, 8))}');
    if (digits.length > 8) result.write('-${digits.substring(8, digits.length.clamp(8, 10))}');
    if (digits.length > 10) result.write('-${digits.substring(10, digits.length)}');

    return result.toString();
  }

  /// Kursorni foydalanuvchi yozgan raqamdan keyin qoldiradi: maska belgilari
  /// qo'shilgani uchun oddiy siljish joyini adashtiradi.
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
