import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/katm_labels.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_fields.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bitta KATM shartnomasining to'liq tafsiloti.
///
/// Ichki ro'yxatlar (oylik qoldiqlar, to'lov jadvallari, ta'minotlar) aynan shu
/// yerda chiziladi: bitta shartnomada yuzlab yozuv bo'lishi mumkin, shuning
/// uchun ular ro'yxat kartochkasida emas, faqat tafsilot ochilganda quriladi.
Future<void> showKatmContract({required BuildContext context, required KatmRow contract}) =>
    showAppSheet(context: context, child: KatmContractSheet(contract: contract));

final class KatmContractSheet extends StatelessWidget {
  const KatmContractSheet({super.key, required this.contract});

  final KatmRow contract;

  @override
  Widget build(BuildContext context) {
    final Map<String, String> columns = <String, String>{
      ...KatmLabels.columns['contracts'] ?? const <String, String>{},
      ...KatmLabels.contractDetail,
    };

    final List<KatmNested> nested = contract.nested
        .where((KatmNested item) => item.rows.isNotEmpty && KatmLabels.nestedTitles.containsKey(item.key))
        .toList();

    final String title = contract.valueOf('org_name');

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
            child: Text(
              title.isEmpty ? "Shartnoma" : KatmLabels.translate(title),
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),
          ),

          Gap(ScreenSize.h10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(ScreenSize.h12, 0, ScreenSize.h12, ScreenSize.h20),
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(ScreenSize.h12),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.white,
                    borderRadius: BorderRadius.circular(ScreenSize.r16),
                    border: AppSurface.border(),
                  ),
                  child: KatmFields(row: contract, labels: columns),
                ),

                Gap(ScreenSize.h10),
                ...nested.map(_section),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(KatmNested nested) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h8),
    child: Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey<String>(nested.key),
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
          KatmLabels.nestedTitles[nested.key] ?? nested.key,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(
            color: AppTheme.colors.blackSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text("${nested.rows.length} ta yozuv", style: AppTheme.data.textTheme.bodySmall),
        children: nested.rows.map((KatmRow row) => _row(nested.key, row)).toList(),
      ),
    ),
  );

  Widget _row(String key, KatmRow row) {
    final String primaryKey = KatmLabels.nestedPrimary[key] ?? '';
    final String title = primaryKey.isEmpty ? '' : row.valueOf(primaryKey);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h8),
      padding: EdgeInsets.all(ScreenSize.h10),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: AppSurface.border(alpha: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title.isNotEmpty) ...<Widget>[
            Text(
              KatmLabels.translate(title),
              style: AppTheme.data.textTheme.titleMedium?.copyWith(
                color: AppTheme.colors.blackSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
            Gap(ScreenSize.h4),
          ],

          KatmFields(row: row, labels: KatmLabels.nestedColumns[key] ?? const <String, String>{}),
        ],
      ),
    );
  }
}
