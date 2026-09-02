import 'package:flutter/services.dart';

/// `dd.MM.yyyy` — nuqtalar avtomatik qo'yiladi.
final class BirthDateFormatter extends TextInputFormatter {
  static const int _digitCount = 8;
  static const List<int> _dotAfter = <int>[2, 4];

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    final String capped = digits.length > _digitCount ? digits.substring(0, _digitCount) : digits;

    final StringBuffer result = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (_dotAfter.contains(i)) result.write('.');
      result.write(capped[i]);
    }

    final String text = result.toString();

    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
