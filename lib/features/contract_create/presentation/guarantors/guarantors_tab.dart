import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/contract_guarantors/contract_guarantors_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/guarantor_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/guarantor_issue_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Kafil tanlash natijasi. Faqat oddiy tiplar — `contract_create` mijozlar
/// featureini import qilmaydi (1.3).
typedef GuarantorPickResult = ({int clientId, String fullName, String passport});

/// «Kafillar» tabi.
final class GuarantorsTab extends StatelessWidget {
  const GuarantorsTab({super.key, required this.guarantorPicker});

  /// Mijozlar ekranini kafil rejimida ochadi: tanlash → oferta → yuz
  /// tekshiruvi, yoki noldan yangi mijoz.
  final Future<GuarantorPickResult?> Function(BuildContext context) guarantorPicker;

  Future<void> _add(BuildContext context) async {
    final ContractGuarantorsBloc bloc = context.read<ContractGuarantorsBloc>();
    final GuarantorPickResult? pick = await guarantorPicker(context);

    if (pick == null) return;

    bloc.add(GuarantorAdded(clientId: pick.clientId, fullName: pick.fullName, passport: pick.passport));
  }

  Future<void> _remove(BuildContext context, ContractGuarantor guarantor) async {
    final ContractGuarantorsBloc bloc = context.read<ContractGuarantorsBloc>();

    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AppDialog(
        icon: AppIcons.delete,
        accent: AppTheme.colors.red,
        title: "Kafilni o'chirish",
        message: "«${guarantor.fullName}» shartnomadan olib tashlanadi.",
        actionLabel: "O'chirish",
        cancelLabel: "Bekor qilish",
        onAction: () => Navigator.of(context).pop(true),
      ),
    );

    if (!(isConfirmed ?? false)) return;

    bloc.add(GuarantorRemoved(guarantor.clientId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractGuarantorsBloc, ContractGuarantorsState>(
      builder: (BuildContext context, ContractGuarantorsState state) {
        final String? issue = GuarantorIssueText.of(state.issue);

        return ListView(
          padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h14, ScreenSize.h16, ScreenSize.h24),
          children: <Widget>[
            for (final ContractGuarantor item in state.guarantors)
              GuarantorCard(
                guarantor: item,
                isBusy: state.busyId == item.clientId,
                removePress: () => unawaited(_remove(context, item)),
              ),

            if (state.guarantors.isEmpty) ...<Widget>[
              Text("Kafil qo'shilmagan", style: AppTheme.data.textTheme.bodySmall),
              Gap(ScreenSize.h10),
            ],

            // Chegaraga yetganda tugma o'rniga sababi turadi: yo'qolib qolgan
            // tugma foydalanuvchiga hech nima aytmaydi (5.8).
            if (state.isFull)
              Text(
                "Ko'pi bilan ${ContractGuarantorsState.maxGuarantors} ta kafil qo'shiladi",
                style: AppTheme.data.textTheme.bodySmall,
              )
            else
              _addButton(context, state),

            if (issue != null) ...<Widget>[
              Gap(ScreenSize.h8),
              Text(issue, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
            ],

            Gap(ScreenSize.h12),
            Text(
              "Kafil oferta va yuz tekshiruvidan o'tadi. Imzolashda yana bir marta tekshiriladi.",
              style: AppTheme.data.textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }

  Widget _addButton(BuildContext context, ContractGuarantorsState state) => InkWell(
    onTap: state.isAdding ? null : () => unawaited(_add(context)),
    borderRadius: BorderRadius.circular(ScreenSize.r18),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .3)),
      ),
      child: state.isAdding
          ? Center(
              child: SizedBox(
                width: ScreenSize.h20,
                height: ScreenSize.h20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.person_add_alt_1_outlined, size: ScreenSize.h20, color: AppTheme.colors.primary),
                Gap(ScreenSize.w6),
                Text(
                  "Kafil qo'shish",
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
                ),
              ],
            ),
    ),
  );
}

/// Qoralama hali yo'q — kafil qo'shib bo'lmaydi.
final class GuarantorsPlaceholder extends StatelessWidget {
  const GuarantorsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: EdgeInsets.all(ScreenSize.h24),
      child: Text(
        "Kafil birinchi tovar qo'shilgandan keyin qo'shiladi",
        textAlign: TextAlign.center,
        style: AppTheme.data.textTheme.bodySmall,
      ),
    ),
  );
}
