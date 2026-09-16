import 'dart:async';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/cards/section_card.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/option_sheet.dart';
import 'package:colloborator_v3/features/credit_calculator/domain/entities/credit_calculation.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/bloc/credit_calculator_bloc.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/styles/calculator_text.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/widgets/calculation_result_card.dart';
import 'package:colloborator_v3/features/credit_calculator/presentation/widgets/max_percent_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// «Kredit kalkulyator» — drawerdan ochiladigan tezkor taxmin ekrani.
/// Serverga murojaat qilmaydi, shuning uchun `data/` qatlami yo'q — barcha
final class CreditCalculatorPage extends StatefulWidget {
  const CreditCalculatorPage({super.key});

  @override
  State<CreditCalculatorPage> createState() => _CreditCalculatorPageState();
}

final class _CreditCalculatorPageState extends State<CreditCalculatorPage> {
  final TextEditingController _price = TextEditingController();
  final TextEditingController _frontMargin = TextEditingController(text: "${CreditCalculation.defaultFrontMarginPercent}");
  final TextEditingController _backMargin = TextEditingController(text: "${CreditCalculation.defaultBackMarginPercent}");

  late final CreditCalculatorBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CreditCalculatorBloc>();
  }

  @override
  void dispose() {
    _price.dispose();
    _frontMargin.dispose();
    _backMargin.dispose();
    super.dispose();
  }

  Future<void> _pickTerm(int current) => showOptionSheet<int>(
    context: context,
    title: CalculatorText.termLabel,
    options: List<int>.generate(CreditCalculation.maxTermMonths - CreditCalculation.minTermMonths + 1,(int i) => CreditCalculation.minTermMonths + i),
    labelOf: CalculatorText.termValue,
    isSelected: (int value) => value == current,
    onPicked: (int value) => _bloc.add(TermSelected(value)),
  );

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: Stack(
        children: <Widget>[
          const BackgroundWash(),

          Positioned.fill(
            child: BlocBuilder<CreditCalculatorBloc, CreditCalculatorState>(
              builder: (BuildContext context, CreditCalculatorState state) => _content(state, topInset),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: PageHeader(title: CalculatorText.title, topInset: topInset, backPress: context.pop),
          ),
        ],
      ),
    );
  }

  Widget _content(CreditCalculatorState state, double topInset) {
    final CreditCalculation calculation = state.calculation;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        ScreenSize.h16,
        topInset + ScreenSize.h56 + ScreenSize.h12,
        ScreenSize.h16,
        ScreenSize.h24,
      ),
      children: <Widget>[
        CalculationSummary(calculation: calculation),

        Gap(ScreenSize.h12),
        SectionCard(
          title: CalculatorText.formTitle,
          icon: Icons.tune_rounded,
          accent: AppTheme.colors.primary,
          isDivided: false,
          children: <Widget>[_form(calculation)],
        ),

        CalculationBreakdown(calculation: calculation),

        Text(
          CalculatorText.disclaimer,
          style: AppTheme.data.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _form(CreditCalculation calculation) => Padding(
    padding: EdgeInsets.fromLTRB(ScreenSize.h14, 0, ScreenSize.h14, ScreenSize.h6),
    child: Column(
      children: <Widget>[
        TextInputWidget(
          title: CalculatorText.priceLabel,
          hint: CalculatorText.priceHint,
          controller: _price,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
          onChanged: (String value) => _bloc.add(PriceChanged(Money.parse(value))),
        ),

        Gap(ScreenSize.h14),
        SelectTile(
          title: CalculatorText.termLabel,
          hint: CalculatorText.termHint,
          value: CalculatorText.termValue(calculation.termMonths),
          onTap: () => unawaited(_pickTerm(calculation.termMonths)),
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          title: CalculatorText.frontMarginLabel,
          hint: CalculatorText.marginHint(CreditCalculation.minMarginPercent, CreditCalculation.maxFrontMarginPercent),
          controller: _frontMargin,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            MaxPercentFormatter(max: CreditCalculation.maxFrontMarginPercent),
          ],
          onChanged: (String value) => _bloc.add(FrontMarginChanged(int.tryParse(value) ?? 0)),
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          title: CalculatorText.backMarginLabel,
          hint: CalculatorText.marginHint(CreditCalculation.minMarginPercent, CreditCalculation.maxBackMarginPercent),
          controller: _backMargin,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            MaxPercentFormatter(max: CreditCalculation.maxBackMarginPercent),
          ],
          onChanged: (String value) => _bloc.add(BackMarginChanged(int.tryParse(value) ?? 0)),
        ),
      ],
    ),
  );
}
