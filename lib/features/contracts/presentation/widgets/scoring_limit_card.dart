import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// Limit bo'limi: umumiy summa, band qilingan ulush va ikkita ko'rsatkich.
final class ScoringLimitCard extends StatelessWidget {
  const ScoringLimitCard({super.key, required this.limits});

  final ScoringLimits limits;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: "Limit ma'lumotlari",
      icon: AppIcons.creditcard,
      color: AppTheme.colors.primary,
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: ScreenSize.h12, horizontal: ScreenSize.w12),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(ScreenSize.r15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Umumiy limit", style: AppTheme.data.textTheme.bodyMedium),

                Gap(ScreenSize.h4),
                Text(
                  "${_sumFormat.format(limits.total)} so'm",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.displayLarge?.copyWith(
                    color: AppTheme.colors.primary,
                    fontSize: ScreenSize.sp22,
                  ),
                ),

                Gap(ScreenSize.h10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(ScreenSize.r8),
                  child: LinearProgressIndicator(
                    value: limits.usedShare,
                    minHeight: ScreenSize.h6,
                    color: AppTheme.colors.primary,
                    backgroundColor: AppTheme.colors.primary.withValues(alpha: .15),
                  ),
                ),

                Gap(ScreenSize.h6),
                Text(
                  "Bo'sh limit: ${_sumFormat.format(limits.free)} so'm",
                  style: AppTheme.data.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          Gap(ScreenSize.h10),
          Row(
            children: <Widget>[
              Expanded(
                child: _tile(
                  "Yetmayotgan limit",
                  limits.exceeded,
                  limits.exceeded > 0 ? AppTheme.colors.red : AppTheme.colors.grey,
                ),
              ),

              Gap(ScreenSize.w10),
              Expanded(child: _tile("Kafillar ulushi", limits.coBorrower, AppTheme.colors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(String title, int value, Color color) => Container(
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.data.textTheme.bodySmall),

        Gap(ScreenSize.h4),
        Text(
          "${_sumFormat.format(value)} so'm",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
