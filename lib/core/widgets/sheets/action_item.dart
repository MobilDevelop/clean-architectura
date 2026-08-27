import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Amal oynasidagi bitta qator.
final class ActionItem extends StatelessWidget {
  const ActionItem({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      // Nega avval yopilib, keyin amal: amal navigatsiya qilsa, keyin
      // chaqirilgan `pop` yangi ochilgan sahifani yopib yuborardi.
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenSize.h8, horizontal: ScreenSize.h6),
        child: Row(
          children: <Widget>[
            Container(
              height: ScreenSize.h42,
              width: ScreenSize.h42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(ScreenSize.r14),
                border: Border.all(color: color.withValues(alpha: .22)),
              ),
              child: SvgPicture.asset(
                icon,
                height: ScreenSize.h20,
                width: ScreenSize.h20,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),

            Gap(ScreenSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),

                  Gap(ScreenSize.h2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            Gap(ScreenSize.w8),
            SvgPicture.asset(
              AppIcons.arrowRight,
              height: ScreenSize.h16,
              colorFilter: ColorFilter.mode(AppTheme.colors.grey.withValues(alpha: .6), BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }
}
