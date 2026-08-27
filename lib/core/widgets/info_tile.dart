import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ikonka + yorliq + qiymat plitkasi.
final class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.icon, required this.label, required this.value, this.isEmpty = false});

  final String icon;
  final String label;
  final String value;

  /// Qiymat o'rnida "yo'q" ma'nosidagi matn turibdimi.
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h8),
      decoration: BoxDecoration(
        color: AppTheme.colors.backcolor.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: AppSurface.border(alpha: .6),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            icon,
            height: ScreenSize.h16,
            width: ScreenSize.h16,
            colorFilter: ColorFilter.mode(AppTheme.colors.grey, BlendMode.srcIn),
          ),

          Gap(ScreenSize.w8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: AppTheme.data.textTheme.labelMedium),

                Gap(ScreenSize.h2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(
                    color: isEmpty ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
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
