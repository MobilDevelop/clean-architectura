import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/scoring_check_text.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ichki tekshiruvlar. Sarlavhadagi belgi nechtasi o'tganini ko'rsatadi.
final class InternalChecksCard extends StatelessWidget {
  const InternalChecksCard({super.key, required this.checks, required this.passed});

  final List<InternalCheck> checks;
  final int passed;

  static const String _empty = "Ma'lumot yo'q";

  @override
  Widget build(BuildContext context) {
    final bool allPassed = passed == checks.length;

    return ResultCard(
      title: "Ichki tekshiruvlar",
      icon: AppIcons.approve,
      color: AppTheme.colors.green,
      trailing: ResultChip(
        text: "$passed/${checks.length}",
        color: allPassed ? AppTheme.colors.green : AppTheme.colors.red,
      ),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < checks.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, color: AppSurface.line(alpha: .5)),
            _row(checks[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(InternalCheck check) {
    final bool ok = check.isPassed;
    final Color color = ok ? AppTheme.colors.green : AppTheme.colors.red;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            ok ? AppIcons.success : AppIcons.error,
            height: ScreenSize.h20,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),

          Gap(ScreenSize.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  ScoringCheckText.internal(check.kind),
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),

                Gap(ScreenSize.h2),
                Text(
                  check.detail.isEmpty ? _empty : check.detail,
                  style: AppTheme.data.textTheme.bodySmall?.copyWith(
                    color: check.detail.isEmpty ? AppTheme.colors.grey : color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
