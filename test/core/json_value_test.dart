import 'package:colloborator_v3/core/utils/json_value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Beshta DTO shu yordamchiga tayanadi — semantikasi bir joyda qulflanadi.
  group('toInt', () {
    test('son va satr bir xil o‘qiladi', () {
      expect(JsonValue.toInt(1800000), 1800000);
      expect(JsonValue.toInt('1800000'), 1800000);
    });

    // `int.tryParse` kasrli satrda `null` beradi — shuning uchun `num`.
    test('kasrli satr butun songa aylanadi', () => expect(JsonValue.toInt('1800000.00'), 1800000));

    test('o‘qib bo‘lmasa nol', () {
      expect(JsonValue.toInt(null), 0);
      expect(JsonValue.toInt('1 800 000'), 0);
      expect(JsonValue.toInt(''), 0);
    });
  });

  // Nol va "yo'q" bir xil ma'noni bermaydigan maydonlar uchun.
  group('toNullableInt', () {
    test('yo‘q qiymat null bo‘lib qoladi', () => expect(JsonValue.toNullableInt(null), isNull));
    test('buzuq qiymat ham null', () => expect(JsonValue.toNullableInt('abc'), isNull));
    test('nol — haqiqiy nol', () => expect(JsonValue.toNullableInt(0), 0));
  });

  group('toText', () {
    test('null bo‘sh satr', () => expect(JsonValue.toText(null), ''));
    test('son satrga aylanadi', () => expect(JsonValue.toText(12), '12'));
  });

  group('toDigits', () {
    test('maskadagi belgilar tushadi', () {
      expect(JsonValue.toDigits('+998 90 123-45-67'), '998901234567');
      expect(JsonValue.toDigits('(90) 123-45-67'), '901234567');
    });

    test('null bo‘sh satr', () => expect(JsonValue.toDigits(null), ''));
  });

  // Identifikatorlar uchun: yo'qlik meʼyoriy `0` emas — bu yozuv kimligini
  // bildiradi (4.6).
  group('requireInt', () {
    test('son va satr o‘qiladi', () {
      expect(JsonValue.requireInt(42, field: 'id'), 42);
      expect(JsonValue.requireInt('42', field: 'id'), 42);
    });

    test('yo‘q bo‘lsa yiqiladi', () {
      expect(() => JsonValue.requireInt(null, field: 'id'), throwsFormatException);
    });

    test('songa aylanmasa yiqiladi', () {
      expect(() => JsonValue.requireInt('abc', field: 'id'), throwsFormatException);
    });
  });

  // `_flag` bilan bir xil mantiq: yo'qlik meʼyoriy, buzuq shakl — nosozlik.
  group('numOrDefault', () {
    test('kalit yo‘q bo‘lsa standart qiymat', () {
      expect(JsonValue.numOrDefault(const <String, dynamic>{}, 'total', 0), 0);
      expect(JsonValue.numOrDefault(const <String, dynamic>{'total': null}, 'total', 0), 0);
    });

    test('son yoki songa aylanadigan satr o‘qiladi', () {
      expect(JsonValue.numOrDefault(const <String, dynamic>{'total': 15000}, 'total', 0), 15000);
      expect(JsonValue.numOrDefault(const <String, dynamic>{'total': '15000'}, 'total', 0), 15000);
    });

    test('kalit bor-u son emas — yiqiladi', () {
      expect(
        () => JsonValue.numOrDefault(const <String, dynamic>{'total': 'noma\'lum'}, 'total', 0),
        throwsFormatException,
      );
    });
  });
}
