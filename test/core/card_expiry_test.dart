import 'package:colloborator_v3/core/utils/card_expiry.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sana qat'iy: qoida ilgari `DateTime.now()` ga bog'langan edi va uni umuman
/// sinab bo'lmasdi (9.4). Bugun 2026-yil sentabr deb olinadi.
final DateTime _now = DateTime(2026, 9, 12);

bool _usable(int month, int year) => CardExpiry.isUsable(month: month, year: year, now: _now);

void main() {
  test('joriy oy — yaroqli', () => expect(_usable(9, 26), isTrue));

  test('kelasi oy — yaroqli', () => expect(_usable(10, 26), isTrue));

  test('o‘tgan oy — yaroqsiz', () => expect(_usable(8, 26), isFalse));

  test('o‘tgan yil — yaroqsiz', () => expect(_usable(12, 25), isFalse));

  test('oy oralig‘i tekshiriladi', () {
    expect(_usable(0, 27), isFalse);
    expect(_usable(13, 27), isFalse);
  });

  // Karta bugungidan besh yil oldinga amal qilishi mumkin.
  test('chegaradagi yil — yaroqli', () => expect(_usable(9, 31), isTrue));

  test('chegaradan oshgan — yaroqsiz', () {
    expect(_usable(10, 31), isFalse);
    expect(_usable(1, 32), isFalse);
  });

  // Yil `0` — muddat umuman kiritilmagan holat.
  test('yil kiritilmagan — yaroqsiz', () => expect(_usable(9, 0), isFalse));
}
