import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// Skoringdagi bitta shartnoma.
final class ScoringContractCard extends StatelessWidget {
  const ScoringContractCard({super.key, required this.contract});

  final ScoringContract contract;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h8),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        border: contract.hasOverdue
            ? Border.all(color: AppTheme.colors.red.withValues(alpha: .4))
            : AppSurface.border(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  contract.branch.isEmpty ? "Filial ko'rsatilmagan" : contract.branch,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),

              if (contract.hasOverdue)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h2),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.red.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(ScreenSize.r8),
                  ),
                  child: Text(
                    "Muddati o'tgan",
                    style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red),
                  ),
                ),
            ],
          ),

          Gap(ScreenSize.h6),
          _row("Sana", contract.date.isEmpty ? "—" : contract.date),
          _row("Muddat", "${contract.termMonths} oy"),
          _row("Oylik to'lov", "${_sumFormat.format(contract.monthlyPayment)} so'm"),
          _row("Qoldiq qarz", "${_sumFormat.format(contract.totalDebt)} so'm"),
          if (contract.status.isNotEmpty) _row("Holat", contract.status),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: EdgeInsets.only(top: ScreenSize.h2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),

        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.bodyLarge?.copyWith(color: AppTheme.colors.blackSoft),
          ),
        ),
      ],
    ),
  );
}
