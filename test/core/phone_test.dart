import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/utils/uz_phone.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Foydalanuvchi maydonga yozgandek qilib formatlaydi.
String _typed(String input) {
  final PhoneFormatter formatter = PhoneFormatter();

  return formatter
      .formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: input, selection: TextSelection.collapsed(offset: input.length)),
      )
      .text;
}

void main() {
  group('UzPhone', () {
    test('to‘liq va tanilgan operator — yaroqli', () {
      expect(UzPhone.isValid('998901234567'), isTrue);
      expect(UzPhone.isValid('998201234567'), isTrue);
    });

    test('tanilmagan operator kodi — yaroqsiz', () => expect(UzPhone.isValid('998121234567'), isFalse));

    test('to‘liq bo‘lmagan raqam — yaroqsiz', () {
      expect(UzPhone.isValid('99890123456'), isFalse);
      expect(UzPhone.isValid(''), isFalse);
    });

    // Operator kodi raqam to'liq bo'lmasa ham tekshiriladi — shuning uchun
    // uzunlik alohida qaraladi.
    test('operator kodi qisman raqamda ham tanilodi', () {
      expect(UzPhone.hasOperator('99890'), isTrue);
      expect(UzPhone.hasOperator('99812'), isFalse);
      expect(UzPhone.hasOperator('998'), isFalse);
    });
  });

  group('PhoneFormatter', () {
    test('mamlakat kodi o‘zi qo‘shiladi', () => expect(_typed('901234567'), '+998 90 123-45-67'));

    test('mamlakat kodi bilan yozilsa takrorlanmaydi', () =>
        expect(_typed('998901234567'), '+998 90 123-45-67'));

    test('ortiqcha raqam kesiladi', () => expect(_typed('9989012345679999'), '+998 90 123-45-67'));

    test('bo‘sh qiymat bo‘sh qoladi', () => expect(_typed(''), ''));

    // Formatter endi tekshirmaydi: yaroqsiz operator kodi ham kiritiladi,
    // xato esa maydon tagida `issue` orqali ko'rinadi (7.5). Ilgari formatter
    // kiritishni rad etib, toast chiqarardi.
    test('yaroqsiz operator kodi rad etilmaydi', () {
      expect(_typed('121234567'), '+998 12 123-45-67');
      expect(UzPhone.isValid('998121234567'), isFalse);
    });

    test('mask tayyor raqamni formatlaydi', () {
      expect(PhoneFormatter.mask('998901234567'), '+998 90 123-45-67');
      expect(PhoneFormatter.mask(''), '');
    });
  });
}
