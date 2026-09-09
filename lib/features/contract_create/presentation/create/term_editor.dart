import 'dart:async';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/core/widgets/sheets/option_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Muddat va to'lov kuni — bitta qatorda, ikkita maydon.
///
/// Nega stepper va chiplar emas: ular birgalikda ekranning uchdan birini
/// egallardi. Qiymat baribir ko'rinib turadi, o'zgartirish esa kamdan-kam
/// kerak — shuning uchun tanlash oynaga chiqarildi.
final class TermEditor extends StatelessWidget {
  const TermEditor({
    super.key,
    required this.form,
    required this.isLocked,
    required this.dayError,
    required this.termChanged,
    required this.dayChanged,
  });

  final ContractForm form;

  /// Server amali ketayotganda o'zgartirish bloklanadi.
  final bool isLocked;

  /// To'lov kuni tanlanmaganini bildiruvchi matn. Widget uni hisoblamaydi (6.7).
  final String? dayError;

  final ValueChanged<int> termChanged;
  final ValueChanged<int> dayChanged;

  Future<void> _pickTerm(BuildContext context) => showOptionSheet<int>(
    context: context,
    title: "Shartnoma muddati",
    options: List<int>.generate(
      ContractForm.maxTerm - ContractForm.minTerm + 1,
      (int i) => ContractForm.minTerm + i,
    ),
    labelOf: (int value) => "$value oy",
    isSelected: (int value) => value == form.termMonths,
    onPicked: termChanged,
  );

  Future<void> _pickDay(BuildContext context) => showOptionSheet<int>(
    context: context,
    title: "To'lov kuni",
    options: form.paymentDays,
    labelOf: (int value) => "Har oyning $value-kuni",
    isSelected: (int value) => value == form.paymentDay,
    onPicked: (int value) => dayChanged(form.paymentDays.indexOf(value)),
  );

  @override
  Widget build(BuildContext context) {
    final bool hasDays = form.paymentDays.isNotEmpty;
    final String? error = dayError;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _field(
                  icon: Icons.schedule_rounded,
                  accent: AppTheme.colors.primary,
                  label: "Muddat",
                  value: "${form.termMonths} oy",
                  onTap: isLocked ? null : () => unawaited(_pickTerm(context)),
                ),
              ),

              Gap(ScreenSize.w8),
              Expanded(
                child: _field(
                  icon: Icons.event_available_rounded,
                  accent: AppTheme.colors.blue,
                  label: "To'lov kuni",
                  value: hasDays ? "${form.paymentDay}-kun" : "keyinroq",
                  isEmpty: !hasDays,
                  onTap: isLocked || !hasDays ? null : () => unawaited(_pickDay(context)),
                ),
              ),
            ],
          ),

          if (error != null) ...<Widget>[
            Gap(ScreenSize.h8),
            Row(
              children: <Widget>[
                Icon(Icons.error_outline_rounded, size: ScreenSize.h16, color: AppTheme.colors.red),
                Gap(ScreenSize.w6),
                Text(error, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _field({required IconData icon,required Color accent,required String label,required String value,required VoidCallback? onTap,bool isEmpty = false}) {
    final Color tone = onTap == null ? AppTheme.colors.grey1 : accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h8),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(ScreenSize.r14),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: ScreenSize.h18, color: tone),
            Gap(ScreenSize.w8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: AppTheme.data.textTheme.bodySmall),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: isEmpty ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                    ),
                  ),
                ],
              ),
            ),

            if (onTap != null)
              Icon(Icons.expand_more_rounded, size: ScreenSize.h18, color: AppTheme.colors.grey),
          ],
        ),
      ),
    );
  }
}
