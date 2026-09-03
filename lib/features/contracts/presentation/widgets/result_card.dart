import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Natija ekranidagi bo'lim: sarlavha, ikonka va ixtiyoriy belgi.
final class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.trailing,
  });

  final String title;
  final String icon;
  final Color color;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final Widget? badge = trailing;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ScreenSize.h12),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SvgPicture.asset(
                icon,
                height: ScreenSize.h18,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),

              Gap(ScreenSize.w8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),

              ?badge,
            ],
          ),

          Gap(ScreenSize.h10),
          child,
        ],
      ),
    );
  }
}

/// Kichik belgi: "3/4" yoki "2 ta sabab".
final class ResultChip extends StatelessWidget {
  const ResultChip({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(ScreenSize.r10),
      ),
      child: Text(
        text,
        style: AppTheme.data.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
