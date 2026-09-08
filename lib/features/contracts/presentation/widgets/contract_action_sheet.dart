import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_divider.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_item.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_sheet.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_actions.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_action_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_sheet_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Shartnoma ustidagi amallar oynasi.
///
/// Qaysi tugma faol ekanini oyna hisoblamaydi — `ContractActions` aytadi.
/// Tasdiqlash va bekor qilish oynaning ichida bajariladi: ular so'rov yuboradi
/// va natijasi ko'rinishi kerak. [onChanged] muvaffaqiyatdan keyin chaqiriladi —
/// ro'yxat eskirgan bo'ladi.
Future<void> showContractActions({
  required BuildContext context,
  required ContractInfo contract,
  required VoidCallback pressEdit,
  required VoidCallback pressDetails,
  required VoidCallback onChanged,
  required VoidCallback onSigningRequested,
}) => showActionSheet(
  context: context,
  header: ContractSheetHeader(contract: contract),
  actions: <Widget>[
    BlocProvider<ContractActionBloc>(
      create: (BuildContext context) => getIt<ContractActionBloc>(param1: contract)..add(const ActionsRequested()),
      child: _Actions(
        pressEdit: pressEdit,
        pressDetails: pressDetails,
        onChanged: onChanged,
        onSigningRequested: onSigningRequested,
      ),
    ),
  ],
);

final class _Actions extends StatelessWidget {
  const _Actions({
    required this.pressEdit,
    required this.pressDetails,
    required this.onChanged,
    required this.onSigningRequested,
  });

  final VoidCallback pressEdit;
  final VoidCallback pressDetails;
  final VoidCallback onChanged;
  final VoidCallback onSigningRequested;

  @override
  Widget build(BuildContext context) {
    final ContractActionBloc bloc = context.read<ContractActionBloc>();

    return BlocConsumer<ContractActionBloc, ContractActionState>(
      listenWhen: (ContractActionState previous, ContractActionState current) =>
          (current.isDone && !previous.isDone) || (current.isSigningRequested && !previous.isSigningRequested),
      listener: (BuildContext context, ContractActionState state) {
        Navigator.of(context).pop();

        if (state.isDone) {
          onChanged();
          return;
        }

        onSigningRequested();
      },
      builder: (BuildContext context, ContractActionState state) {
        final ContractActions actions = state.actions;

        // Xato oynaning ichida ko'rsatiladi: sahifadagi banner modal ostida
        // qolib ketadi. Sessiya xatosi esa dialog bilan tugaydi (5.6).
        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const ActionsRequested()),
          child: Column(
            children: <Widget>[
              if (state.isLoading)
                Padding(
                  padding: EdgeInsets.only(bottom: ScreenSize.h10),
                  child: LinearProgressIndicator(
                    minHeight: ScreenSize.h2,
                    color: AppTheme.colors.primary,
                    backgroundColor: AppTheme.colors.primary.withValues(alpha: .15),
                  ),
                ),

              // Amal mumkin emasligining sababi tugmaning o'zida emas, tepada.
              if (actions.warning.isNotEmpty) _warning(actions.warning),

              // Birinchi qator to'rt holatdan biri: kutish, qayta urinish,
              // ruxsat berish / yuborish, yoki tasdiqlash.
              if (!actions.isReady && state.failure == null)
                ActionItem(
                  icon: AppIcons.approve,
                  color: AppTheme.colors.grey,
                  title: "Tekshirilmoqda...",
                  subtitle: "Vakolat tekshirilmoqda",
                  enabled: false,
                  onTap: () {},
                )
              else if (!actions.isReady)
                ActionItem(
                  icon: AppIcons.refresh,
                  color: AppTheme.colors.yellow,
                  title: "Qayta urinish",
                  subtitle: "Vakolatni tekshirib bo'lmadi",
                  closeOnTap: false,
                  onTap: () => bloc.add(const ActionsRequested()),
                )
              else if (actions.needsConfirmation)
                ActionItem(
                  icon: actions.approve == ApproveAction.allow ? AppIcons.approve : AppIcons.sendUp,
                  color: actions.approve == ApproveAction.allow ? AppTheme.colors.primary : AppTheme.colors.yellow,
                  title: actions.approve == ApproveAction.allow ? "Ruxsat berish" : "Yuborish",
                  subtitle: actions.approve == ApproveAction.allow
                      ? "Shartnomaga ruxsat berish"
                      : "Vakolatli shaxsga yuborish",
                  enabled: actions.canApprove && !state.isLoading,
                  closeOnTap: false,
                  onTap: () => unawaited(_confirmApprove(context, bloc, actions.approve)),
                )
              else
                ActionItem(
                  icon: AppIcons.approve,
                  color: AppTheme.colors.primary,
                  title: "Tasdiqlash",
                  subtitle: "Shartnomani tasdiqlash",
                  enabled: actions.canApprove && !state.isLoading,
                  closeOnTap: false,
                  onTap: () => bloc.add(const ApprovePressed()),
                ),

              const ActionDivider(),
              ActionItem(
                icon: AppIcons.edit,
                color: AppTheme.colors.yellow,
                title: "Tahrirlash",
                subtitle: "Shartnomani o'zgartirish",
                enabled: actions.canEdit,
                onTap: pressEdit,
              ),

              const ActionDivider(),
              ActionItem(
                icon: AppIcons.info,
                color: AppTheme.colors.blue,
                title: "Batafsil",
                subtitle: "Skoring, MIB va KATM natijalari",
                onTap: pressDetails,
              ),

              const ActionDivider(),
              ActionItem(
                icon: AppIcons.delete,
                color: AppTheme.colors.red,
                title: "Bekor qilish",
                subtitle: "Shartnomani bekor qilish",
                enabled: actions.canCancel && !state.isLoading,
                closeOnTap: false,
                onTap: () => unawaited(_confirmCancel(context, bloc)),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Ruxsat berish va yuborish ham tasdiq so'raydi — ikkalasi ham shartnomani
  /// boshqa bosqichga o'tkazadi.
  Future<void> _confirmApprove(BuildContext context, ContractActionBloc bloc, ApproveAction action) async {
    final bool isAllow = action == ApproveAction.allow;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: isAllow ? AppIcons.approve : AppIcons.sendUp,
        accent: isAllow ? AppTheme.colors.primary : AppTheme.colors.yellow,
        title: isAllow ? "Ruxsat berish" : "Yuborish",
        message: isAllow
            ? "Ushbu shartnoma bo'yicha ruxsat berilsinmi?"
            : "Shartnomani tasdiqlash uchun vakolatli shaxsga yuborasizmi?",
        actionLabel: isAllow ? "Ruxsat berish" : "Yuborish",
        cancelLabel: "Yopish",
        onAction: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed ?? false) bloc.add(const ApprovePressed());
  }

  /// Bekor qilish qaytarib bo'lmaydigan amal — avval tasdiq so'raladi.
  Future<void> _confirmCancel(BuildContext context, ContractActionBloc bloc) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: AppIcons.delete,
        accent: AppTheme.colors.red,
        title: "Shartnomani bekor qilish",
        message: "Bekor qilingan shartnomani tiklab bo'lmaydi. Davom etasizmi?",
        actionLabel: "Bekor qilish",
        cancelLabel: "Yopish",
        onAction: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (confirmed ?? false) bloc.add(const CancelConfirmed());
  }

  Widget _warning(String message) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: ScreenSize.h10),
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.yellow.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(ScreenSize.r12),
      border: Border.all(color: AppTheme.colors.yellow.withValues(alpha: .3)),
    ),
    child: Row(
      children: <Widget>[
        Icon(Icons.info_outline_rounded, color: AppTheme.colors.yellow, size: ScreenSize.h18),

        Gap(ScreenSize.w8),
        Expanded(
          child: Text(
            message,
            style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.3),
          ),
        ),
      ],
    ),
  );
}
