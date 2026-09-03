import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Map<String, String> cases = <String, String>{
    '998901234567': '+998 90 123-45-67',
    '+998901234567': '+998 90 123-45-67',
    '901234567': '+998 90 123-45-67',
    '+998 90 123-45-67': '+998 90 123-45-67',
    '99890123456789': '+998 90 123-45-67',
    '': '',
  };

  cases.forEach((String input, String expected) {
    test('"$input" → "$expected"', () => expect(PhoneFormatter.mask(input), expected));
  });
}
