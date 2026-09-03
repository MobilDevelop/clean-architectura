import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final NumberFormat _sumFormat = NumberFormat.decimalPattern('uz');

/// Skoringning asosiy natijasi: ruxsat etilgan summa va ball.
final class ScoringHeader extends StatelessWidget {
  const ScoringHeader({super.key, required this.info});

  final ScoringInfo info;

  @override
  Widget build(BuildContext context) {
    final bool isApproved = info.isScored && info.isClean;
    final Color color = isApproved ? AppTheme.colors.primary : AppTheme.colors.red;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenSize.h16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            isApproved ? "Ruxsat berildi" : "Ruxsat berilmadi",
            style: AppTheme.data.textTheme.titleLarge?.copyWith(color: color),
          ),

          Gap(ScreenSize.h8),
          Text(
            "${_sumFormat.format(info.permissionSum)} so'm",
            style: AppTheme.data.textTheme.displayLarge?.copyWith(
              color: AppTheme.colors.blackSoft,
              fontSize: ScreenSize.sp24,
            ),
          ),

          Gap(ScreenSize.h12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _ball("Ball", info.ball),
              Container(width: 1, height: ScreenSize.h28, color: color.withValues(alpha: .25)),
              _ball("Kafillik balli", info.guarantorBall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ball(String label, num value) => Column(
    children: <Widget>[
      Text(label, style: AppTheme.data.textTheme.bodyMedium),

      Gap(ScreenSize.h2),
      Text(
        value.toString(),
        style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
      ),
    ],
  );
}
