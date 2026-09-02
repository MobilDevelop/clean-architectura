import 'package:colloborator_v3/features/customers/presentation/formatters/birth_date_formatter.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/passport_number_formatter.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/passport_series_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

String _apply(TextInputFormatter formatter, String input) =>
    formatter.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: input)).text;

void main() {
  group('PassportSeriesFormatter', () {
    final PassportSeriesFormatter formatter = PassportSeriesFormatter();

    const Map<String, String> cases = <String, String>{
      'aa': 'AA',
      'AAA': 'AA',
      'a-a 1': 'AA',
      '12ab': 'AB',
      '1234': '',
    };

    cases.forEach((String input, String expected) {
      test('"$input" → "$expected"', () => expect(_apply(formatter, input), expected));
    });
  });

  group('PassportNumberFormatter', () {
    final PassportNumberFormatter formatter = PassportNumberFormatter();

    const Map<String, String> cases = <String, String>{
      '1234567': '1234567',
      '12345678901': '1234567',
      'a1b2c3': '123',
      'abc': '',
    };

    cases.forEach((String input, String expected) {
      test('"$input" → "$expected"', () => expect(_apply(formatter, input), expected));
    });
  });

  group('BirthDateFormatter', () {
    final BirthDateFormatter formatter = BirthDateFormatter();

    const Map<String, String> cases = <String, String>{
      '01011990': '01.01.1990',
      '0101199012': '01.01.1990',
      '01.01.1990': '01.01.1990',
      '1': '1',
      '012': '01.2',
      'abc01': '01',
    };

    cases.forEach((String input, String expected) {
      test('"$input" → "$expected"', () => expect(_apply(formatter, input), expected));
    });
  });
}
