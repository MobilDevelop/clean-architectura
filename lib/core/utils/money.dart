import 'package:intl/intl.dart';

/// Pul bilan ishlash. Summalar butun so'mda saqlanadi.
///
/// Nega alohida: flex formatlangan satrdan `[\s,.]` ni olib tashlab songa
/// aylantiradi — kasrli narx shu yerda 100 barobar kattalashadi. Bu yerda
/// faqat raqamlar olinadi va kasr belgisi umuman qabul qilinmaydi.
abstract final class Money {
  static final NumberFormat _format = NumberFormat.decimalPattern('uz');

  static final RegExp _notDigit = RegExp(r'[^0-9]');

  /// Kiritilgan matndan summa. Raqam bo'lmasa `0`.
  static int parse(String value) {
    final String digits = value.replaceAll(_notDigit, '');

    return digits.isEmpty ? 0 : int.tryParse(digits) ?? 0;
  }

  /// `1800000` → `1 800 000`.
  static String format(num value) => _format.format(value);

  /// Ko'rsatish uchun: `1 800 000 so'm`.
  static String withUnit(num value) => "${format(value)} so'm";
}
