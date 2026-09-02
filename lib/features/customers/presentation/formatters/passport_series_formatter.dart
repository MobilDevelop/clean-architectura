import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:flutter/services.dart';

/// Pasport seriyasi: ikkita bosh harf.
final class PassportSeriesFormatter extends TextInputFormatter {
  static final RegExp _letter = RegExp('[A-Z]');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final StringBuffer result = StringBuffer();

    for (final String char in newValue.text.toUpperCase().split('')) {
      if (result.length == CustomerSearchShape.passportLetters) break;
      if (_letter.hasMatch(char)) result.write(char);
    }

    final String text = result.toString();

    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}
