  import 'package:flutter/services.dart';
  import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat('#,###', 'en_US');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text.substring(0, cursorPos).replaceAll(RegExp(r'[^0-9]'), '').length;

    final String formatted = formatter.format(int.parse(digits)).replaceAll(',', ' ');

    int digitCount = 0;
    int newCursorOffset = formatted.length;
    for (int i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        if (digitCount == digitsBeforeCursor) {
          newCursorOffset = i;
          break;
        }
        digitCount++;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}

