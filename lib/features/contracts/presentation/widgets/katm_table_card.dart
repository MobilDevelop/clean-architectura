import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/katm_labels.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_contract_sheet.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_fields.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Maketdagi bitta jadval bo'limi. Har bir qator alohida kartochka bo'lib
/// chiziladi — telefonda ustunli jadval o'qilmaydi.
final class KatmTableCard extends StatelessWidget {
  const KatmTableCard({super.key, required this.section, required this.table});

  final KatmSection section;
  final KatmTable table;

  /// Bittada nechta qator ko'rsatiladi. Qolganini foydalanuvchi ochadi.
  static const int _preview = 3;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> columns = KatmLabels.columns[section.key] ?? const <String, String>{};
    final KatmRow? totals = table.totals;

    return ResultCard(
      title: section.title.isEmpty ? section.key : section.title,
      icon: AppIcons.contract,
      color: AppTheme.colors.blue,
      trailing: ResultChip(text: "${table.rows.length} ta", color: AppTheme.colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (totals != null) ...<Widget>[
            Container(
              padding: EdgeInsets.all(ScreenSize.h10),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: .06),
                borderRadius: BorderRadius.circular(ScreenSize.r12),
              ),
              child: KatmFields(row: totals, labels: KatmLabels.totals),
            ),
            Gap(ScreenSize.h10),
          ],

          if (table.rows.isEmpty)
            Text("Ma'lumot yo'q", style: AppTheme.data.textTheme.bodyMedium)
          else
            _rows(context, columns),
        ],
      ),
    );
  }

  Widget _rows(BuildContext context, Map<String, String> columns) {
    final List<KatmRow> visible = table.rows.take(_preview).toList();
    final int hidden = table.rows.length - visible.length;

    return Column(
      children: <Widget>[
        ...visible.map((KatmRow row) => _card(context, row, columns)),

        if (hidden > 0)
          Theme(
            data: ThemeData(dividerColor: Colors.transparent),
            child: ExpansionTile(
              // Ro'yxat siljiganda ochiq holat yo'qolmasligi uchun.
              key: PageStorageKey<String>(section.key),
              tilePadding: EdgeInsets.symmetric(horizontal: ScreenSize.w10),
              childrenPadding: EdgeInsets.zero,
              backgroundColor: AppTheme.colors.backcolor,
              collapsedBackgroundColor: AppTheme.colors.backcolor,
              iconColor: AppTheme.colors.grey,
              collapsedIconColor: AppTheme.colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r12)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r12)),
              title: Text(
                "Yana $hidden ta",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
              ),
              children: table.rows.skip(_preview).map((KatmRow row) => _card(context, row, columns)).toList(),
            ),
          ),
      ],
    );
  }

  /// Ichki ro'yxati bo'lgan qator bosilganda to'liq tafsilot ochiladi.
  Widget _card(BuildContext context, KatmRow row, Map<String, String> columns) {
    final String? primaryKey = KatmLabels.primary[section.key];
    final String title = primaryKey == null ? '' : row.valueOf(primaryKey);
    final bool hasDetail = row.hasNested;

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.h8),
      child: InkWell(
        onTap: hasDetail ? () => unawaited(showKatmContract(context: context, contract: row)) : null,
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        child: Container(
          padding: EdgeInsets.all(ScreenSize.h10),
          decoration: BoxDecoration(
            color: AppTheme.colors.backcolor,
            borderRadius: BorderRadius.circular(ScreenSize.r12),
            border: AppSurface.border(alpha: .5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title.isNotEmpty) ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        KatmLabels.translate(title),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.titleMedium?.copyWith(
                          color: AppTheme.colors.blackSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (hasDetail)
                      Icon(Icons.chevron_right_rounded, color: AppTheme.colors.grey, size: ScreenSize.h20),
                  ],
                ),
                Gap(ScreenSize.h4),
              ],

              KatmFields(row: row, labels: columns),

              if (hasDetail && title.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: ScreenSize.h6),
                  child: Text(
                    "Tafsilotni ochish",
                    style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.primary),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
