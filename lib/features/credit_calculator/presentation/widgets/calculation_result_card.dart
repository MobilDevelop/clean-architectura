import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_cell_row.dart';
import 'package:colloborator_v3/core/widgets/cards/section_card.dart';
import 'package:colloborator_v3/features/credit_calculator/domain/entities/credit_calculation.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/styles/calculator_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Javob: oylik to'lov va shartnoma qiymati.
///
/// Ekranning tepasida turadi — xodim kalkulyatorni aynan shu ikki son uchun
/// ochadi va ular uchun pastga aylantirishi kerak emas.
final class CalculationSummary extends StatelessWidget {
  const CalculationSummary({super.key, required this.calculation});

  final CreditCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final bool has = calculation.hasResult;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(ScreenSize.r18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(CalculatorText.monthlyPaymentRow, style: AppTheme.data.textTheme.bodySmall),

          Gap(ScreenSize.h2),
          Text(
            has ? Money.withUnit(calculation.monthlyPayment) : CalculatorText.noResult,
            style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.primary),
          ),

          Gap(ScreenSize.h8),
          Text(
            has
                ? "${CalculatorText.termValue(calculation.termMonths)} · ${CalculatorText.totalPriceRow.toLowerCase()} ${Money.withUnit(calculation.totalPrice)}"
                : CalculatorText.emptyHint,
            style: AppTheme.data.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Hisobning bosqichlari. Bu yerda hisob yo'q — hammasi
/// `CreditCalculation` ning tayyor maydonlaridan olinadi (6.7).
final class CalculationBreakdown extends StatelessWidget {
  const CalculationBreakdown({super.key, required this.calculation});

  final CreditCalculation calculation;

  @override
  Widget build(BuildContext context) {
    if (!calculation.hasResult) return const SizedBox.shrink();

    return SectionCard(
      title: CalculatorText.resultTitle,
      icon: Icons.calculate_outlined,
      accent: AppTheme.colors.blue,
      isDivided: false,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
          child: Column(
            children: <Widget>[
              // Juftlab qo'yiladi: har qiymat o'z qatorida bo'lsa kartada
              // yettita ajratuvchi chiziq paydo bo'ladi.
              LabeledCellRow(
                cells: <LabeledCell>[
                  LabeledCell(label: CalculatorText.priceRow, value: _value(Money.withUnit(calculation.price))),
                  LabeledCell(
                    label: CalculatorText.frontMarginRow,
                    value: _value("+${calculation.frontMarginPercent}%"),
                  ),
                ],
              ),

              LabeledCellRow(
                cells: <LabeledCell>[
                  LabeledCell(
                    label: CalculatorText.sellingPriceRow,
                    value: _value(Money.withUnit(calculation.sellingPrice)),
                  ),
                  LabeledCell(
                    label: CalculatorText.backMarginRow,
                    value: _value("+${calculation.backMarginPercent}%"),
                  ),
                ],
              ),

              LabeledCellRow(
                isLast: !calculation.showLastMonthPayment,
                cells: <LabeledCell>[
                  LabeledCell(
                    label: CalculatorText.totalPriceRow,
                    value: _value(Money.withUnit(calculation.totalPrice), strong: true),
                  ),
                ],
              ),

              // Faqat yaxlitlash farqi bo'lganda. Sababi yozilmasa xodim
              // buni xato deb o'ylaydi.
              if (calculation.showLastMonthPayment) ...<Widget>[
                LabeledCellRow(
                  isLast: true,
                  cells: <LabeledCell>[
                    LabeledCell(
                      label: CalculatorText.lastMonthPaymentRow,
                      value: _value(Money.withUnit(calculation.lastMonthPayment)),
                    ),
                  ],
                ),

                Gap(ScreenSize.h8),
                Text(CalculatorText.roundingHint, style: AppTheme.data.textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _value(String text, {bool strong = false}) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: AppTheme.data.textTheme.titleLarge?.copyWith(
      color: AppTheme.colors.black,
      fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
    ),
  );
}
