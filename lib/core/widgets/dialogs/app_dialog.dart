import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ilovadagi barcha dialoglarning ramkasi.
///
/// Nega alohida: dialog foydalanuvchini to'xtatadi, ya'ni u eng ko'rinadigan
/// element. Uning ko'rinishi bir joyda saqlansa, hech qaysi ekran o'zicha
/// boshqacha dialog chizib qo'ymaydi.
final class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String icon;
  final Color accent;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: ScreenSize.h24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r24)),
      child: Padding(
        padding: EdgeInsets.all(ScreenSize.h20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: ScreenSize.h64,
              width: ScreenSize.h64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .10),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: .22)),
              ),
              child: SvgPicture.asset(
                icon,
                height: ScreenSize.h28,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),

            Gap(ScreenSize.h16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(height: 1.4),
            ),

            Gap(ScreenSize.h20),
            MainButton(text: actionLabel, onPressed: onAction),
          ],
        ),
      ),
    );
  }
}
