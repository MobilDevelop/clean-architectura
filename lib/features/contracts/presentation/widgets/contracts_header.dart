import 'dart:ui';

import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/circle_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

final DateFormat _dayFormat = DateFormat('dd.MM.yyyy');

/// Shartnomalar ro'yxatining suzuvchi sarlavhasi.
final class ContractsHeader extends StatelessWidget {
  const ContractsHeader({
    super.key,
    required this.topInset,
    required this.date,
    required this.drawerPress,
    required this.filterPress,
    required this.clearDate,
  });

  final double topInset;

  /// Tanlangan sana. `null` — filtr qo'yilmagan.
  final DateTime? date;
  final VoidCallback drawerPress;
  final VoidCallback filterPress;
  final VoidCallback clearDate;

  @override
  Widget build(BuildContext context) {
    final DateTime? selected = date;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppSurface.blurSigma, sigmaY: AppSurface.blurSigma),
        child: Container(
          padding: EdgeInsets.only(top: topInset, left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h8),
          decoration: BoxDecoration(
            color: AppTheme.colors.backcolor.withValues(alpha: AppSurface.panelAlpha),
            border: Border(bottom: BorderSide(color: AppSurface.line(alpha: .6))),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenSize.h48,
                child: Row(
                  children: <Widget>[
                    CircleIconButton(icon: AppIcons.drawer, onTap: drawerPress),

                    Gap(ScreenSize.w12),
                    Expanded(
                      child: Text(
                        "Shartnomalar",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                      ),
                    ),

                    CircleIconButton(
                      icon: AppIcons.calendar,
                      onTap: filterPress,
                      // Filtr yoqilganini tugmaning o'zi ham ko'rsatadi.
                      color: selected == null ? null : AppTheme.colors.primary,
                    ),
                  ],
                ),
              ),

              // Faol filtr sarlavha ostida ko'rinib turadi — foydalanuvchi
              // ro'yxat nega qisqarganini eslab qolishi shart emas.
              AnimatedSize(
                duration: Duration(milliseconds: AppConstants.duration),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: selected == null
                  ? const SizedBox(width: double.infinity)
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(top: ScreenSize.h8),
                        child: _ActiveFilterChip(label: _dayFormat.format(selected), onClear: clearDate),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Qo'llanilgan filtr va uni olib tashlash tugmasi.
final class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: onClear,
      child: Container(
        height: ScreenSize.h32,
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.colors.primary.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(ScreenSize.r16),
          border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              label,
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                color: AppTheme.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),

            Gap(ScreenSize.w8),
            SvgPicture.asset(
              AppIcons.close,
              height: ScreenSize.h12,
              colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
