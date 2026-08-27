import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_divider.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_item.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_sheet.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/contract_status_style.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnoma ustidagi amallar oynasi.
Future<void> showContractActions({
  required BuildContext context,
  required ContractInfo contract,
  required VoidCallback pressApprove,
  required VoidCallback pressEdit,
  required VoidCallback pressDetails,
  required VoidCallback pressCancel,
}) => showActionSheet(
  context: context,
  header: _ContractSheetHeader(contract: contract),
  actions: <Widget>[
    ActionItem(
      icon: AppIcons.approve,
      color: AppTheme.colors.primary,
      title: "Tasdiqlash",
      subtitle: "Shartnomani tasdiqlash",
      onTap: pressApprove,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.edit,
      color: AppTheme.colors.yellow,
      title: "Tahrirlash",
      subtitle: "Shartnomani o'zgartirish",
      onTap: pressEdit,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.info,
      color: AppTheme.colors.blue,
      title: "Batafsil",
      subtitle: "To'liq ma'lumotni ko'rish",
      onTap: pressDetails,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.delete,
      color: AppTheme.colors.red,
      title: "Bekor qilish",
      subtitle: "Shartnomani bekor qilish",
      onTap: pressCancel,
    ),
  ],
);

final class _ContractSheetHeader extends StatelessWidget {
  const _ContractSheetHeader({required this.contract});

  final ContractInfo contract;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = ContractStatusStyle.color(contract.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          contract.clientFio,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft, letterSpacing: -0.2),
        ),

        Gap(ScreenSize.h6),
        Row(
          children: <Widget>[
            Text("№ ${contract.id}", style: AppTheme.data.textTheme.bodyMedium),

            Gap(ScreenSize.w8),
            CircleAvatar(radius: ScreenSize.r2, backgroundColor: AppTheme.colors.grey1),

            Gap(ScreenSize.w8),
            Flexible(
              child: Text(
                ContractStatusStyle.label(contract.status),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
