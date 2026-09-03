import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// MIB hisobotining sarlavhasi: qarzdor, jami summa va uchta ko'rsatkich.
final class MibSummaryCard extends StatelessWidget {
  const MibSummaryCard({super.key, required this.report});

  final MibReport report;

  @override
  Widget build(BuildContext context) {
    final Color color = report.hasDebt ? AppTheme.colors.red : AppTheme.colors.primary;

    return ResultCard(
      title: report.title.isEmpty ? "Ijro hujjatlari" : report.title,
      icon: AppIcons.file,
      color: color,
      trailing: ResultChip(
        text: report.hasDebt ? "${report.debts.length} ta hujjat" : "Qarz yo'q",
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (report.debtorName.isNotEmpty) ...<Widget>[
            Text(
              report.debtorName,
              style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
            ),
            if (report.inps.isNotEmpty)
              Text("INPS: ${report.inps}", style: AppTheme.data.textTheme.bodySmall),
            Gap(ScreenSize.h10),
          ],

          if (report.headline.isNotEmpty) ...<Widget>[
            Text(
              report.headline,
              style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
            ),
            Gap(ScreenSize.h10),
          ],

          _row("Umumiy qarzdorlik", report.totals.total, color),
          _row("Joriy qarzdorlik", report.totals.current, AppTheme.colors.blackSoft),
          _row("Reestrdagi qarzdorlik", report.totals.registry, AppTheme.colors.blackSoft),

          if (report.scoredAt.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h8),
            Text("Tekshirilgan: ${report.scoredAt}", style: AppTheme.data.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _row(String title, double value, Color color) => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title, style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),

        Flexible(
          child: Text(
            "${_sumFormat.format(value)} so'm",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
