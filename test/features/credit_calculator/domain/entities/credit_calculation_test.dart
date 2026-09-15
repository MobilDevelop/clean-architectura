import 'package:colloborator_v3/features/credit_calculator/domain/entities/credit_calculation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('narx kiritilmaguncha natija yo‘q', () {
    final calculation = CreditCalculation.initial();

    expect(calculation.hasResult, isFalse);
    expect(calculation.sellingPrice, 0);
    expect(calculation.totalPrice, 0);
    expect(calculation.monthlyPayment, 0);
  });

  test('front va bek marja ketma-ket qo‘shiladi', () {
    const calculation = CreditCalculation(
      price: 3000000,
      termMonths: 8,
      frontMarginPercent: 5,
      backMarginPercent: 15,
    );

    expect(calculation.sellingPrice, 3150000);
    expect(calculation.totalPrice, 3622500);
  });

  // Oylik to'lov yuqoriga yaxlitlanadi, farq oxirgi oyda qaytariladi —
  // shuning uchun oxirgi oy oylikdan sal kam bo'ladi.
  test('oylik to‘lov yuqoriga yaxlitlanadi, oxirgi oy farqni qaytaradi', () {
    const calculation = CreditCalculation(
      price: 3000000,
      termMonths: 8,
      frontMarginPercent: 5,
      backMarginPercent: 15,
    );

    expect(calculation.monthlyPayment, 452813);
    expect(calculation.lastMonthPayment, 452809);
    expect(calculation.showLastMonthPayment, isTrue);
  });

  test('jami muddatga qoldiqsiz bo‘linsa oxirgi oy ko‘rsatilmaydi', () {
    const calculation = CreditCalculation(
      price: 800000,
      termMonths: 8,
      frontMarginPercent: 0,
      backMarginPercent: 0,
    );

    expect(calculation.monthlyPayment, 100000);
    expect(calculation.showLastMonthPayment, isFalse);
  });
}
