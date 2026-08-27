import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:flutter/services.dart';

/// Mijoz qidiruvi maydonidagi matnni yozilayotganda shakllantiradi.
///
/// Bitta maydonga uch xil ma'lumot kiritiladi, shuning uchun birinchi belgiga
/// qarab tarmoqlanadi: raqam — INPS, harf+raqam — pasport, qolgani — ism.
/// Bu yerda faqat **ko'rinish** hal qilinadi; matn qaysi turga tegishli ekani va
/// u bilan qidirsa bo'ladimi — [CustomerSearchParams] ning ishi.
final class CustomerSearchFormatter extends TextInputFormatter {
  CustomerSearchFormatter();

  static final RegExp _letters = RegExp('[${CustomerSearchShape.letters}]');
  static final RegExp _digits = RegExp(r'\d');
  static final RegExp _nonDigits = RegExp(r'\D');
  static final RegExp _spaces = RegExp(r'\s');
  static final RegExp _repeatedSpaces = RegExp(r'\s+');
  static final RegExp _fullNameAllowed = RegExp("[${CustomerSearchShape.letters}\\s\\-']");
  static final RegExp _passportStart =
      RegExp('^[${CustomerSearchShape.letters}]{${CustomerSearchShape.passportLetters}}\\d');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.trim().isEmpty) return newValue;

    final firstChar = text.trimLeft()[0];
    final cursorPos = newValue.selection.end.clamp(0, text.length);

    if (_digits.hasMatch(firstChar)) return _formatInps(text, cursorPos);

    if (_letters.hasMatch(firstChar)) {
      final compact = text.replaceAll(_spaces, '');
      if (_passportStart.hasMatch(compact)) return _formatPassport(text, compact, cursorPos);

      return _formatFullName(text, cursorPos);
    }

    return oldValue;
  }

  /// Faqat raqamlar, INPS uzunligigacha.
  TextEditingValue _formatInps(String text, int cursorPos) {
    String result = text.replaceAll(_nonDigits, '');
    if (result.length > CustomerSearchShape.inpsDigits) {
      result = result.substring(0, CustomerSearchShape.inpsDigits);
    }

    final digitsBeforeCursor = text.substring(0, cursorPos).replaceAll(_nonDigits, '').length;

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: digitsBeforeCursor.clamp(0, result.length)),
    );
  }

  /// Ikki harf katta registrda, keyin pasport raqami uzunligigacha raqam.
  TextEditingValue _formatPassport(String text, String compact, int cursorPos) {
    const letters = CustomerSearchShape.passportLetters;
    const digits = CustomerSearchShape.passportDigits;

    final prefix = compact.substring(0, letters).toUpperCase();
    final numbers = compact.substring(letters).replaceAll(_nonDigits, '');
    final result = '$prefix${numbers.length > digits ? numbers.substring(0, digits) : numbers}';

    final int newOffset;
    if (cursorPos <= letters) {
      newOffset = cursorPos.clamp(0, result.length);
    } else {
      final digitsInSuffix = text.substring(letters, cursorPos).replaceAll(_nonDigits, '').length;
      newOffset = (letters + digitsInSuffix).clamp(0, result.length);
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  /// Ruxsat etilgan belgilar, bitta probel va har so'z bosh harfda.
  /// Uzunlik bu yerda cheklanmaydi — buni `LengthLimitingTextInputFormatter` qiladi.
  TextEditingValue _formatFullName(String text, int cursorPos) {
    final allowed = text.split('').where(_fullNameAllowed.hasMatch).join();
    final compact = allowed.replaceAll(_repeatedSpaces, ' ').trimLeft();
    final endsWithSpace = allowed.endsWith(' ') && compact.isNotEmpty;

    final words = compact
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + (word.length > 1 ? word.substring(1).toLowerCase() : ''))
        .toList();

    final result = endsWithSpace ? '${words.join(' ')} ' : words.join(' ');

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursorPos.clamp(0, result.length)),
    );
  }
}
