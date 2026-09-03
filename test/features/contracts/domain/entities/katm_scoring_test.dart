import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:flutter_test/flutter_test.dart';

KatmScoring _scoring({int grade = 250, int min = 0, int max = 500}) =>
    KatmScoring(grade: grade, className: '', level: '', min: min, max: max, bands: const <KatmBand>[]);

void main() {
  group('KatmScoring', () {
    test('shkala kelmasa gauge chizilmaydi', () {
      expect(_scoring(min: 0, max: 0).hasScale, isFalse);
      expect(_scoring(min: 0, max: 0).position, 0);
    });

    test('o‘rtadagi ball', () => expect(_scoring(grade: 250).position, .5));

    test('shkaladan pastdagi ball 0 ga qisiladi', () => expect(_scoring(grade: -50).position, 0));

    test('shkaladan yuqoridagi ball 1 ga qisiladi', () => expect(_scoring(grade: 900).position, 1));

    test('nolga bo‘linmaydi', () => expect(_scoring(grade: 100, min: 300, max: 300).position, 0));
  });

  group('KatmRow', () {
    const KatmRow row = KatmRow(<KatmField>[
      KatmField(key: 'amount', value: '12000000', isMoney: true),
      KatmField(key: 'contract_id', value: '01180', isMoney: false),
    ]);

    test('kalit bo‘yicha topadi', () => expect(row.field('amount')?.value, '12000000'));
    test('yo‘q kalit uchun null', () => expect(row.field('yoq'), isNull));
    test('kod maydoni summa emas', () => expect(row.field('contract_id')?.isMoney, isFalse));
  });
}
