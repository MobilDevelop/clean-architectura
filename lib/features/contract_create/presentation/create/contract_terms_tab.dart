import 'dart:async';

import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_extra_style.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/extra_entry_row.dart';
import 'package:colloborator_v3/core/widgets/cards/section_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/card_section.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/income_chips.dart';
import 'package:colloborator_v3/core/widgets/sheets/option_sheet.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/term_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// «Shartnoma» tabi: muddat, to'lov kuni, daromad va qo'shimcha ekranlarga
/// kirish.
///
/// Scroll qiladi. Flex'da bu bir xil kontent scroll qilmaydigan `Column` da
/// turgan va to'lgan holatda ekrandan toshib ketgan.
final class ContractTermsTab extends StatelessWidget {
  const ContractTermsTab({super.key, required this.state, required this.extraPressed});

  final ContractCreateState state;
  final void Function(ContractExtra extra) extraPressed;

  Future<void> _pickOccupation(BuildContext context) {
    final ContractCreateBloc bloc = context.read<ContractCreateBloc>();

    return showOptionSheet<OccupationType>(
      context: context,
      title: "Qo'shimcha daromad turi",
      options: state.form.catalog.items,
      labelOf: (OccupationType e) => e.name,
      isSelected: (OccupationType e) => e.id == state.form.occupation.id,
      onPicked: (OccupationType e) => bloc.add(OccupationSelected(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ContractCreateBloc bloc = context.read<ContractCreateBloc>();

    return ListView(
      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h14, ScreenSize.h16, ScreenSize.h24),
      children: <Widget>[
        SectionCard(
          title: "Shartlar",
          icon: Icons.description_outlined,
          accent: AppTheme.colors.primary,
          isDivided: false,
          children: <Widget>[
            TermEditor(
              form: state.form,
              isLocked: state.isSubmitting,
              dayError: state.issue == ContractFormIssue.paymentDayMissing ? "To'lov kunini tanlang" : null,
              termChanged: (int value) => bloc.add(TermChanged(value)),
              dayChanged: (int index) => bloc.add(PaymentDaySelected(index)),
            ),
          ],
        ),

        SectionCard(
          title: "Daromad",
          icon: Icons.account_balance_wallet_outlined,
          accent: AppTheme.colors.primary,
          isDivided: false,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
              child: IncomeChips(
                isInformal: state.form.basis == IncomeBasis.informal,
                hasCarIncome: state.form.hasCarIncome,
                lockedReason: state.canChangeBasis ? null : "Karta biriktirilgan — daromad rasmiy hisoblanadi",
                basisPressed: () => bloc.add(BasisChanged( state.form.basis == IncomeBasis.informal ? IncomeBasis.formal : IncomeBasis.informal)),
                carPressed: () => bloc.add(const CarIncomeToggled()),
              ),
            ),

            if (state.isOccupationVisible)
              Padding(
                padding: EdgeInsets.fromLTRB(ScreenSize.h14, ScreenSize.h10, ScreenSize.h14, 0),
                child: SelectTile(
                  title: "Qo'shimcha daromad turi",
                  hint: "Tanlang",
                  value: state.form.occupation.name,
                  errorText: state.issue == ContractFormIssue.occupationMissing ? "Qo'shimcha daromad turini tanlang" : null,
                  onTap: () => unawaited(_pickOccupation(context)),
                ),
              ),

            // Karta — daromadning boshqa turdagi qismi: u darhol serverga
            // yoziladi, kalitlar esa faqat yuborishda. Chiziq shu farqni
            // ko'rsatadi.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h10),
              child: Divider(height: 1, thickness: 1, color: AppSurface.line(alpha: .5)),
            ),

            if (state.hasContract)
              CardSection(
                // Norasmiy daromadda karta so'ralmaydi.
                isEnabled: state.form.basis == IncomeBasis.formal,
                disabledReason: "Norasmiy daromad yoqilgan — karta talab qilinmaydi",
                saved: () => bloc.add(const ContractRequested()),
              )
            else
              const CardPlaceholder(),
          ],
        ),

        SectionCard(
          title: "Qo'shimcha",
          icon: Icons.more_horiz_rounded,
          accent: AppTheme.colors.grey,
          children: <Widget>[
            for (final ContractExtraRow row in state.extras.rows)
              ExtraEntryRow(
                title: ContractExtraStyle.title(row.extra),
                hint: ContractExtraStyle.hint(row.extra),
                icon: ContractExtraStyle.icon(row.extra),
                accent: ContractExtraStyle.color(row.extra),
                blockReason: ContractExtraStyle.block(row.block),
                onTap: () => extraPressed(row.extra),
              ),
          ],
        ),
      ],
    );
  }
}
