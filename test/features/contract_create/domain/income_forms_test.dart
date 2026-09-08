import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardForm', () {
    const CardForm full = CardForm(phone: '998901234567', number: '8600123412341234', expiry: '0930');

    test('to‘liq forma xatosiz', () => expect(full.issue, CardFieldIssue.none));

    test('telefon 12 raqamdan kam bo‘lsa xato', () {
      expect(full.copyWith(phone: '99890').issue, CardFieldIssue.phoneIncomplete);
    });

    test('karta 16 raqamdan kam bo‘lsa xato', () {
      expect(full.copyWith(number: '86001234').issue, CardFieldIssue.numberIncomplete);
    });

    test('muddat 4 raqamdan kam bo‘lsa xato', () {
      expect(full.copyWith(expiry: '09').issue, CardFieldIssue.expiryIncomplete);
    });

    test('oy 12 dan katta bo‘lsa xato', () {
      expect(full.copyWith(expiry: '1330').issue, CardFieldIssue.expiryInvalid);
    });

    test('oy va yil ajratiladi', () {
      expect(full.month, 9);
      expect(full.year, 30);
    });
  });

  group('IncomeBasis', () {
    test('rasmiy — serverga true', () => expect(IncomeBasis.formal.isFormal, isTrue));
    test('norasmiy — serverga false', () => expect(IncomeBasis.informal.isFormal, isFalse));

    test('serverdan o‘qish teskari nomlanmaydi', () {
      expect(IncomeBasis.of(isFormal: true), IncomeBasis.formal);
      expect(IncomeBasis.of(isFormal: false), IncomeBasis.informal);
    });
  });

  group('BonusForm', () {
    const BonusForm approved = BonusForm(decision: BonusDecision.approved, amount: 100, comment: 'sabab');

    test('to‘g‘ri forma xatosiz', () {
      expect(approved.issueAt(availableAmount: 200), BonusIssue.none);
    });

    test('summa limitdan oshsa xato', () {
      expect(approved.issueAt(availableAmount: 50), BonusIssue.amountTooLarge);
    });

    test('summa nolda xato', () {
      expect(approved.copyWith(amount: 0).issueAt(availableAmount: 200), BonusIssue.amountMissing);
    });

    test('rad etishda summa tekshirilmaydi', () {
      const BonusForm rejected = BonusForm(decision: BonusDecision.rejected, comment: 'sabab');

      expect(rejected.issueAt(availableAmount: 0), BonusIssue.none);
    });

    test('izoh chegaralari', () {
      expect(approved.copyWith(comment: 'ab').issueAt(availableAmount: 200), BonusIssue.commentTooShort);
      expect(
        approved.copyWith(comment: 'a' * 256).issueAt(availableAmount: 200),
        BonusIssue.commentTooLong,
      );
    });

    test('qaror serverga satr bilan ketadi', () {
      expect(BonusDecision.approved.code, 'APPROVED');
      expect(BonusDecision.rejected.code, 'REJECTED');
    });
  });

  group('KatmSkipForm', () {
    test('sabab tanlanmagan bo‘lsa xato', () {
      expect(const KatmSkipForm(comment: 'izoh').issue, KatmSkipIssue.reasonMissing);
    });

    test('izoh bo‘sh bo‘lsa xato', () {
      const KatmSkipForm form = KatmSkipForm(reason: SkipReason(id: 1, name: 'sabab'), comment: '   ');

      expect(form.issue, KatmSkipIssue.commentMissing);
    });

    test('to‘liq forma xatosiz', () {
      const KatmSkipForm form = KatmSkipForm(reason: SkipReason(id: 1, name: 'sabab'), comment: 'izoh');

      expect(form.issue, KatmSkipIssue.none);
    });
  });

  group('ContractForm', () {
    test('muddat chegaradan chiqmaydi', () {
      const ContractForm form = ContractForm.initial();

      expect(form.withTerm(0).termMonths, 1);
      expect(form.withTerm(99).termMonths, 12);
    });

    test('serverdagi ro‘yxatda bo‘lmagan kun birinchisiga tushadi', () {
      const ContractForm form = ContractForm.initial();

      expect(form.withPaymentDays(<int>[5, 15], preferredDay: 20).paymentDay, 5);
      expect(form.withPaymentDays(<int>[5, 15], preferredDay: 15).paymentDay, 15);
    });
  });
}
