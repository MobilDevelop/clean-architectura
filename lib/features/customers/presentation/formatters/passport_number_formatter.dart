import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:flutter/services.dart';

/// Pasport raqami: yettita raqam.
final class PassportNumberFormatter extends TextInputFormatter {
  static final RegExp _digit = RegExp('[0-9]');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final StringBuffer result = StringBuffer();

    for (final String char in newValue.text.split('')) {
      if (result.length == CustomerSearchShape.passportDigits) break;
      if (_digit.hasMatch(char)) result.write(char);
    }

    final String text = result.toString();

    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
