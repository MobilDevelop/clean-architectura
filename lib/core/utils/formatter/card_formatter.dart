import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Maksimal 16 ta raqam
    if (digits.length > 16) {
      digits = digits.substring(0, 16);
    }

    if (digits.length == 16) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text.substring(0, cursorPos).replaceAll(RegExp(r'\D'), '').length;

    String formatted = "";

    for (int i = 0; i < digits.length; i++) {
      formatted += digits[i];
      // har 4 raqamdan keyin bo'sh joy qo'y
      if ((i + 1) % 4 == 0 && i + 1 != digits.length) {
        formatted += " ";
      }
    }

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