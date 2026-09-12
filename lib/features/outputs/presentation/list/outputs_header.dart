import 'dart:ui';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/circle_icon_button.dart';
import 'package:colloborator_v3/features/outputs/presentation/shared/output_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final DateFormat _dayFormat = DateFormat('dd.MM.yyyy');

/// Chiqim tovarlar ro'yxatining suzuvchi sarlavhasi.
final class OutputsHeader extends StatelessWidget {
  const OutputsHeader({
    super.key,
    required this.topInset,
    required this.date,
    required this.filterPress,
    required this.clearDate,
  });

  final double topInset;

  /// Tanlangan sana. `null` — filtr qo'yilmagan, server bugungi kunni beradi.
  final DateTime? date;

  final VoidCallback filterPress;
  final VoidCallback clearDate;

  @override
  Widget build(BuildContext context) {
    final DateTime? selected = date;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppSurface.blurSigma, sigmaY: AppSurface.blurSigma),
        child: Container(
          padding: EdgeInsets.only(
            top: topInset,
            left: ScreenSize.h12,
            right: ScreenSize.h12,
            bottom: ScreenSize.h8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.colors.backcolor.withValues(alpha: AppSurface.panelAlpha),
            border: Border(bottom: BorderSide(color: AppSurface.line(alpha: .6))),
          ),
          child: SizedBox(
            height: ScreenSize.h48,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    OutputText.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),
                ),

                if (selected != null) ...<Widget>[
                  _dateChip(selected),
                  Gap(ScreenSize.w8),
                ],

                CircleIconButton(icon: AppIcons.calendar, onTap: filterPress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Tanlangan sana ko'rinib turadi va shu yerdan tozalanadi — aks holda
  /// bo'sh ro'yxat filtrdanmi yoki ma'lumot yo'qligidanmi bilinmasdi.
  Widget _dateChip(DateTime selected) => InkWell(
    onTap: clearDate,
    borderRadius: BorderRadius.circular(ScreenSize.r12),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _dayFormat.format(selected),
            style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.primary),
          ),

          Gap(ScreenSize.w4),
          Icon(Icons.close_rounded, size: ScreenSize.h14, color: AppTheme.colors.primary),
        ],
      ),
    ),
  );
}
