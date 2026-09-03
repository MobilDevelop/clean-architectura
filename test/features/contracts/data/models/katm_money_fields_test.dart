import 'package:colloborator_v3/features/contracts/data/models/katm_money_fields.dart';
import 'package:flutter_test/flutter_test.dart';

/// KATM summalari so'mda keladi va bo'linmaydi (DEV-4085). Eski ilovada model
/// ularni 100 ga bo'lgan va bu xato deb topilgan — shu yerda qulflanadi.
void main() {
  group('isMoney', () {
    test('summa maydoni', () => expect(KatmMoneyFields.isMoney('total_debt_sum'), isTrue));
    test('yana bir summa', () => expect(KatmMoneyFields.isMoney('amount'), isTrue));
    test('kod maydoni emas', () => expect(KatmMoneyFields.isMoney('contract_id'), isFalse));
    test('foiz emas', () => expect(KatmMoneyFields.isMoney('percent'), isFalse));
    test('sana emas', () => expect(KatmMoneyFields.isMoney('contract_date'), isFalse));
  });

  test('31 ta summa maydoni ro‘yxatda', () => expect(KatmMoneyFields.keys.length, 31));
}
