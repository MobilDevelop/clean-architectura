import 'package:colloborator_v3/core/utils/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parse', () {
    const Map<String, int> cases = <String, int>{
      '1 800 000': 1800000,
      '1800000': 1800000,
      '': 0,
      'abc': 0,
      '0': 0,
      // Kasr belgisi qabul qilinmaydi: bu summa emas, xato kiritish.
      '1 800 000.50': 180000050,
    };

    cases.forEach((String input, int expected) {
      test('"$input" → $expected', () => expect(Money.parse(input), expected));
    });
  });

  group('format', () {
    test('uch xonali guruhlar', () => expect(Money.format(1800000).replaceAll(' ', ' '), '1 800 000'));
    test('nol', () => expect(Money.format(0), '0'));
  });

  test('parse va format teskari amal', () {
    expect(Money.parse(Money.format(1800000)), 1800000);
  });
}
