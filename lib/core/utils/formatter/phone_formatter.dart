import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    final List<String> validOperators = ['90','91','93','94','55','97','88','95','99','77','33','98','92','20','50','87','70'];

    final cursorPos = newValue.selection.end.clamp(0, newValue.text.length);
    final rawDigitsBeforeCursor = newValue.text.substring(0, cursorPos).replaceAll(RegExp(r'\D'), '').length;

    // +998 oldindan qo'yib yuboramiz
    final bool prepended = !digits.startsWith("99");
    if (prepended) {
      digits = "998$digits";
    }

    final int digitsBeforeCursor = prepended ? rawDigitsBeforeCursor + 3 : rawDigitsBeforeCursor;

    // Maksimal uzunlik 12 ta raqam: 998 + 9xx + 7 raqam
    if (digits.length > 12) {
      digits = digits.substring(0, 12);
    }

    if (digits.length >= 5) {
      final op = digits.substring(3, 5);
      if (!validOperators.contains(op)) {
        CustomAnimatedToast.showError("Operator kodi yaroqsiz");
        return oldValue;
      }
    }

    if (digits.length == 12) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    String formatted = "+998";

    if (digits.length > 3) {
      formatted += " ${digits.substring(3, digits.length.clamp(3, 5))}";
    }

    if (digits.length > 5) {
      formatted += " ${digits.substring(5, digits.length.clamp(5, 8))}";
    }

    if (digits.length > 8) {
      formatted += "-${digits.substring(8, digits.length.clamp(8, 10))}";
    }

    if (digits.length > 10) {
      formatted += "-${digits.substring(10, digits.length)}";
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