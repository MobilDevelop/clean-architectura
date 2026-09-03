import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

final class ScoringTotalsCard extends StatelessWidget {
  const ScoringTotalsCard({
    super.key,
    required this.title,
    required this.totals,
    required this.color,
  });

  final String title;
  final ScoringTotals totals;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final num? monthly = totals.monthlyPayment;

    return Container(
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        border: AppSurface.border(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(width: ScreenSize.h4, height: ScreenSize.h16, color: color),

              Gap(ScreenSize.w8),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),

              Text(
                "${totals.count} ta",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.grey),
              ),
            ],
          ),

          Gap(ScreenSize.h8),
          _row("Summa", totals.sum, color),

          // Oylik to'lov faqat aktiv guruhlarda bo'ladi.
          if (monthly != null) ...<Widget>[Gap(ScreenSize.h4), _row("Oylik to'lov", monthly, null)],
        ],
      ),
    );
  }

  Widget _row(String label, num value, Color? valueColor) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Text(label, style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),

      Text(
        "${_sumFormat.format(value)} so'm",
        style: AppTheme.data.textTheme.titleSmall?.copyWith(
          color: valueColor ?? AppTheme.colors.blackSoft,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
