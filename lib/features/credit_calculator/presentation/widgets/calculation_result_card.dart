import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_row.dart';
import 'package:colloborator_v3/features/credit_calculator/domain/entities/credit_calculation.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/styles/calculator_text.dart';
import 'package:flutter/material.dart';

/// Hisob-kitob jadvali. Bu yerda hisob yo'q, faqat ko'rsatish — `Widget qaror
/// qabul qilmaydi` (6.7): hammasi `CreditCalculation` ning tayyor
/// maydonlaridan olinadi.
///
/// Tuzilishi shartnoma va faktura kartalari bilan bir xil (`ContractCard`,
/// `InvoiceCard`): oq karta + «yorliq — qiymat» qatorlari.
final class CalculationResultCard extends StatelessWidget {
  const CalculationResultCard({super.key, required this.calculation});

  final CreditCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final bool has = calculation.hasResult;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            CalculatorText.resultTitle,
            style: AppTheme.data.textTheme.headlineLarge?.copyWith(
              color: AppTheme.colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),

          LabeledRow(
            label: CalculatorText.priceRow,
            value: _value(has ? Money.withUnit(calculation.price) : CalculatorText.noResult),
          ),

          LabeledRow(
            label: CalculatorText.frontMarginRow,
            value: _value("+${calculation.frontMarginPercent}%"),
          ),

          LabeledRow(
            label: CalculatorText.sellingPriceRow,
            value: _value(has ? Money.withUnit(calculation.sellingPrice) : CalculatorText.noResult),
          ),

          LabeledRow(
            label: CalculatorText.backMarginRow,
            value: _value("+${calculation.backMarginPercent}%"),
          ),

          LabeledRow(
            label: CalculatorText.totalPriceRow,
            value: _value(has ? Money.withUnit(calculation.totalPrice) : CalculatorText.noResult, strong: true),
          ),

          LabeledRow(
            label: CalculatorText.monthlyPaymentRow,
            isLast: !calculation.showLastMonthPayment,
            value: _value(
              has ? Money.withUnit(calculation.monthlyPayment) : CalculatorText.noResult,
              accent: true,
            ),
          ),

          // Faqat yaxlitlash farqi bo'lganda: sababi ko'rinmasa xodim buni
          // xato deb o'ylaydi.
          if (calculation.showLastMonthPayment)
            LabeledRow(
              label: CalculatorText.lastMonthPaymentRow,
              isLast: true,
              value: _value(Money.withUnit(calculation.lastMonthPayment)),
            ),
        ],
      ),
    );
  }

  Widget _value(String text, {bool strong = false, bool accent = false}) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: accent
        ? AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.primary, fontWeight: FontWeight.w700)
        : AppTheme.data.textTheme.titleLarge?.copyWith(
            color: AppTheme.colors.black,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
          ),
  );
}
