import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.length > 4) {
      digits = digits.substring(0, 4);
    }

    // Oy birinchi raqami 0 yoki 1 bo'lishi kerak (01-12)
    if (digits.isNotEmpty && digits[0] != '0' && digits[0] != '1') {
      CustomAnimatedToast.showError("Karta muddati yaroqsiz");
      return oldValue;
    }

    // Oy 01-12 oraliqda bo'lishi kerak
    if (digits.length >= 2) {
      final month = int.parse(digits.substring(0, 2));
      if (month < 1 || month > 12) {
        CustomAnimatedToast.showError("Karta muddati yaroqsiz");
        return oldValue;
      }
    }

    if (digits.length == 4) {
      final now = DateTime.now();
      final currentYear = now.year % 100;
      final currentMonth = now.month;
      final month = int.parse(digits.substring(0, 2));
      final year = int.parse(digits.substring(2, 4));

      final isExpired = year < currentYear || (year == currentYear && month < currentMonth);
      if (isExpired) {
        CustomAnimatedToast.showError("Karta muddati yaroqsiz");
        return oldValue;
      }

      final maxYear = currentYear + 5;
      final isOutOfRange = year > maxYear || (year == maxYear && month > currentMonth);
      if (isOutOfRange) {
        CustomAnimatedToast.showError("Karta muddati yaroqsiz");
        return oldValue;
      }

      FocusManager.instance.primaryFocus?.unfocus();
    }

    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final digitsBeforeCursor = newValue.text.substring(0, cursorPos).replaceAll(RegExp(r'\D'), '').length;

    String formatted = "";

    if (digits.isNotEmpty) {
      formatted += digits.substring(0, digits.length.clamp(0, 2));
    }

    if (digits.length > 2) {
      formatted = "${formatted.substring(0, 2)}/${digits.substring(2)}";
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