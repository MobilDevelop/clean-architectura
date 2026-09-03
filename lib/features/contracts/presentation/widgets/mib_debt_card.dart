import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// Bitta ijro hujjati.
final class MibDebtCard extends StatelessWidget {
  const MibDebtCard({super.key, required this.debt});

  final MibDebt debt;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h10),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: AppTheme.colors.red.withValues(alpha: .25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: ScreenSize.h24,
                height: ScreenSize.h24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.colors.red.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${debt.position}",
                  style: AppTheme.data.textTheme.bodySmall?.copyWith(
                    color: AppTheme.colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Gap(ScreenSize.w10),
              Expanded(
                child: Text(
                  debt.workNumber.isEmpty ? "Hujjat raqami yo'q" : "№ ${debt.workNumber}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),

              if (debt.date.isNotEmpty) Text(debt.date, style: AppTheme.data.textTheme.bodySmall),
            ],
          ),

          Gap(ScreenSize.h8),
          Text(
            "${_sumFormat.format(debt.amount)} so'm",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.displayLarge?.copyWith(
              color: AppTheme.colors.red,
              fontSize: ScreenSize.sp18,
            ),
          ),

          if (debt.content.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h8),
            Text(
              debt.content,
              style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
            ),
          ],

          if (debt.creditorName.isNotEmpty || debt.branchName.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h10),
            Divider(height: 1, color: AppSurface.line(alpha: .5)),
            Gap(ScreenSize.h8),
            if (debt.creditorName.isNotEmpty) _row("Undiruvchi", debt.creditorName),
            if (debt.branchName.isNotEmpty) _row("Bo'lim", debt.branchName),
            if (debt.branchPhone.isNotEmpty) _row("Telefon", debt.branchPhone),
          ],
        ],
      ),
    );
  }

  Widget _row(String title, String value) => Padding(
    padding: EdgeInsets.only(top: ScreenSize.h2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(flex: 4, child: Text(title, style: AppTheme.data.textTheme.bodySmall)),

        Gap(ScreenSize.w8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTheme.data.textTheme.bodyLarge?.copyWith(
              color: AppTheme.colors.blackSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
