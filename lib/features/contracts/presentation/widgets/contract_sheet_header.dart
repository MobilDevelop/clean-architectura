import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/core/contract/contract_status_style.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Amallar oynasining sarlavhasi: mijoz, shartnoma raqami va holati.
final class ContractSheetHeader extends StatelessWidget {
  const ContractSheetHeader({super.key, required this.contract});

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
