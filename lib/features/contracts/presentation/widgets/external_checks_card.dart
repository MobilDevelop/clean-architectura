import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/scoring_check_text.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Tashqi tekshiruvlar. Har biri yig'ilgan holda; izoh va sabablar ochilganda
/// ko'rinadi — sakkiztasi birdan ochilsa ekran o'qilmaydi.
final class ExternalChecksCard extends StatelessWidget {
  const ExternalChecksCard({super.key, required this.checks});

  final List<ExternalCheck> checks;

  static const String _empty = "Ma'lumot yo'q";

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: "Tashqi tekshiruvlar",
      icon: AppIcons.info,
      color: AppTheme.colors.blue,
      child: Column(children: checks.map(_tile).toList()),
    );
  }

  Widget _tile(ExternalCheck check) {
    final bool hasName = check.nameUz.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.h8),
      child: Theme(
        // Standart ExpansionTile o'z kulrang chiziqlarini chizadi.
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
              // Ro'yxat siljiganda ochiq holat yo'qolmasligi uchun.
              key: PageStorageKey<String>(check.source.name),
          tilePadding: EdgeInsets.symmetric(horizontal: ScreenSize.w10),
          childrenPadding: EdgeInsets.fromLTRB(ScreenSize.w10, 0, ScreenSize.w10, ScreenSize.h10),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          backgroundColor: AppTheme.colors.backcolor,
          collapsedBackgroundColor: AppTheme.colors.backcolor,
          iconColor: AppTheme.colors.grey,
          collapsedIconColor: AppTheme.colors.grey,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r12)),
          collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r12)),
          title: Text(
            ScoringCheckText.external(check.source),
            style: AppTheme.data.textTheme.titleMedium?.copyWith(
              color: AppTheme.colors.blackSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  hasName ? check.nameUz : _empty,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.bodySmall,
                ),
              ),

              if (check.hasReasons) ...<Widget>[
                Gap(ScreenSize.w6),
                ResultChip(text: "${check.reasons.length} ta sabab", color: AppTheme.colors.yellow),
              ],
            ],
          ),
          children: <Widget>[
            if (check.descriptionUz.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(ScreenSize.h10),
                decoration: BoxDecoration(
                  color: AppTheme.colors.white,
                  borderRadius: BorderRadius.circular(ScreenSize.r10),
                ),
                child: Text(
                  check.descriptionUz,
                  style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
                ),
              ),

            ...check.reasons.map(_reason),

            if (check.descriptionUz.isEmpty && !check.hasReasons)
              Padding(
                padding: EdgeInsets.symmetric(vertical: ScreenSize.h6),
                child: Text(_empty, style: AppTheme.data.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }

  Widget _reason(StopReason reason) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: ScreenSize.h8),
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.red.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(ScreenSize.r10),
      border: Border.all(color: AppTheme.colors.red.withValues(alpha: .2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (reason.code.isNotEmpty)
          Text(
            reason.code,
            style: AppTheme.data.textTheme.bodySmall?.copyWith(
              color: AppTheme.colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),

        Text(
          reason.description.isEmpty ? _empty : reason.description,
          style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
        ),
      ],
    ),
  );
}
