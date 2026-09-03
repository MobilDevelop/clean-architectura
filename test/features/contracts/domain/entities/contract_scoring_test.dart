import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:flutter_test/flutter_test.dart';

const ScoringLimits _empty = ScoringLimits(total: 0, free: 0, exceeded: 0, coBorrower: 0, asokiMonthlyPayment: 0);

void main() {
  group('InternalCheck.isPassed', () {
    test('"Muvaffaqiyatli" matni o‘tgan deb hisoblanadi', () {
      expect(const InternalCheck(kind: InternalCheckKind.age, detail: 'Muvaffaqiyatli o‘tdi').isPassed, isTrue);
    });

    test('boshqa matn o‘tmagan', () {
      expect(const InternalCheck(kind: InternalCheckKind.blacklist, detail: 'Qora ro‘yxatda').isPassed, isFalse);
    });

    test('bo‘sh matn o‘tmagan', () {
      expect(const InternalCheck(kind: InternalCheckKind.clientScore, detail: '').isPassed, isFalse);
    });
  });

  group('ScoringLimits.usedShare', () {
    test('yarmi band', () {
      const ScoringLimits limits = ScoringLimits(
        total: 100,
        free: 50,
        exceeded: 0,
        coBorrower: 0,
        asokiMonthlyPayment: 0,
      );
      expect(limits.usedShare, .5);
    });

    test('limit nol bo‘lsa nolga bo‘linmaydi', () => expect(_empty.usedShare, 0));

    test('bo‘sh limit umumiydan katta bo‘lsa ham 0..1 oralig‘ida qoladi', () {
      const ScoringLimits limits = ScoringLimits(
        total: 100,
        free: 200,
        exceeded: 0,
        coBorrower: 0,
        asokiMonthlyPayment: 0,
      );
      expect(limits.usedShare, 0);
    });
  });

  test('passedInternal o‘tganlarni sanaydi', () {
    const ContractScoring scoring = ContractScoring(
      clientId: 1,
      clientName: 'Test',
      statusCode: 'ok',
      limits: _empty,
      internal: <InternalCheck>[
        InternalCheck(kind: InternalCheckKind.age, detail: 'Muvaffaqiyatli'),
        InternalCheck(kind: InternalCheckKind.blacklist, detail: 'Muvaffaqiyatli'),
        InternalCheck(kind: InternalCheckKind.criminalRecord, detail: 'Topildi'),
        InternalCheck(kind: InternalCheckKind.clientScore, detail: ''),
      ],
      external: <ExternalCheck>[],
    );

    expect(scoring.passedInternal, 2);
  });
}
