import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ulanish uzilganda ekranda turadigan xabar.
///
/// Nega toast emas: aloqa xatosi vaqtincha va foydalanuvchi uni **tuzata
/// oladi**. Toast bir necha soniyada o'chadi va odam nima bo'lganini
/// unutadi; banner esa aloqa tiklanmaguncha ko'rinib turadi.
final class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key, required this.message, required this.onClose, this.onRetry});

  final String message;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Color accent = AppTheme.colors.yellow;
    final VoidCallback? retry = onRetry;

    return Container(
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: accent.withValues(alpha: .35)),
        boxShadow: AppShadow.floating(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: ScreenSize.h36,
            width: ScreenSize.h36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(ScreenSize.r12),
            ),
            child: SvgPicture.asset(
              AppIcons.warning,
              height: ScreenSize.h18,
              colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
            ),
          ),

          Gap(ScreenSize.w10),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.blackSoft),
            ),
          ),

          if (retry != null) ...<Widget>[
            Gap(ScreenSize.w8),
            Bounce(
              duration: Duration(milliseconds: AppConstants.duration),
              onTap: retry,
              child: Container(
                height: ScreenSize.h36,
                padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(ScreenSize.r12),
                  border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .25)),
                ),
                child: Text(
                  "Qayta urinish",
                  style: AppTheme.data.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],

          Gap(ScreenSize.w4),
          Bounce(
            duration: Duration(milliseconds: AppConstants.duration),
            onTap: onClose,
            child: SizedBox(
              height: ScreenSize.h44,
              width: ScreenSize.h36,
              child: Center(
                child: SvgPicture.asset(
                  AppIcons.close,
                  height: ScreenSize.h12,
                  colorFilter: ColorFilter.mode(AppTheme.colors.grey, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
