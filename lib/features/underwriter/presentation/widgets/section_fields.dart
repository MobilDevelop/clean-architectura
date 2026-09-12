import 'dart:async';

import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/option_sheet.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/presentation/bloc/underwriter/underwriter_bloc.dart';
import 'package:colloborator_v3/features/underwriter/presentation/styles/underwriter_text.dart';
import 'package:colloborator_v3/features/underwriter/presentation/widgets/salary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Ochiq bo'limning kiritish maydonlari.
///
/// `sealed` forma ustidagi `switch` — yangi bo'lim qo'shilsa bu yer
/// kompilyatsiyada xato beradi va uni yozishni unutib bo'lmaydi.
final class SectionFields extends StatelessWidget {
  const SectionFields({super.key, required this.state, required this.form});

  final UnderwriterState state;
  final UnderwriterForm form;

  @override
  Widget build(BuildContext context) {
    final UnderwriterBloc bloc = context.read<UnderwriterBloc>();

    return switch (form) {
    SalaryForm(: final List<SalaryRow> rows) => SalarySection(
      rows: rows,
      amountChanged: (int index, int amount) =>
          bloc.add(SalaryAmountChanged(index: index, amount: amount)),
    ),

    PensionForm(: final int amount) => TextInputWidget(
      title: "Pensiya summasi",
      hint: "0",
      initial: amount == 0 ? null : Money.format(amount),
      keyboardType: TextInputType.number,
      formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
      onChanged: (String value) => bloc.add(PensionAmountChanged(Money.parse(value))),
    ),

    MilitaryForm(: final position) => SelectTile(
      title: "Lavozim",
      hint: "Tanlang",
      value: position.name,
      subtitle: position.amount == 0 ? null : Money.withUnit(position.amount),
      onTap: () => unawaited(
        showOptionSheet<MilitaryPosition>(
          context: context,
          title: "Harbiy lavozim",
          options: state.positions,
          emptyText: UnderwriterText.referenceEmpty,
          labelOf: (MilitaryPosition e) => e.name,
          isSelected: (MilitaryPosition e) => e.id == position.id,
          onPicked: (MilitaryPosition e) => bloc.add(PositionSelected(e)),
        ),
      ),
    ),

    CarForm(: final brand, : final model, : final int year) => Column(
      children: <Widget>[
        SelectTile(
          title: "Avtomobil brendi",
          hint: "Tanlang",
          value: brand.name,
          onTap: () => unawaited(
            showOptionSheet<UnderwriterOption>(
              context: context,
              title: "Avtomobil brendi",
              options: state.brands,
              emptyText: UnderwriterText.referenceEmpty,
              labelOf: (UnderwriterOption e) => e.name,
              isSelected: (UnderwriterOption e) => e.id == brand.id,
              onPicked: (UnderwriterOption e) => bloc.add(CarBrandSelected(e)),
            ),
          ),
        ),

        Gap(ScreenSize.h10),
        SelectTile(
          title: "Avtomobil markasi",
          hint: state.isModelsLoading ? "Yuklanmoqda…" : "Tanlang",
          value: model.name,
          // Brend tanlanmaguncha markalar ro'yxati bo'sh bo'ladi.
          enabled: !brand.isEmpty && !state.isModelsLoading,
          onTap: () => unawaited(
            showOptionSheet<UnderwriterOption>(
              context: context,
              title: "Avtomobil markasi",
              options: state.models,
              emptyText: UnderwriterText.modelsEmpty,
              labelOf: (UnderwriterOption e) => e.name,
              isSelected: (UnderwriterOption e) => e.id == model.id,
              onPicked: (UnderwriterOption e) => bloc.add(CarModelSelected(e)),
            ),
          ),
        ),

        Gap(ScreenSize.h10),
        SelectTile(
          title: "Ishlab chiqarilgan yili",
          hint: "Tanlang",
          value: year == 0 ? '' : "$year",
          onTap: () => unawaited(
            showOptionSheet<int>(
              context: context,
              title: "Ishlab chiqarilgan yili",
              options: CarForm.yearsUntil(DateTime.now()),
              labelOf: (int e) => "$e",
              isSelected: (int e) => e == year,
              onPicked: (int e) => bloc.add(CarYearSelected(e)),
            ),
          ),
        ),
      ],
    ),

    StudentForm() => const SizedBox.shrink(),
    };
  }
}
