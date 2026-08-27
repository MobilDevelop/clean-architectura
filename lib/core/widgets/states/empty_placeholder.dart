import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ro'yxat bo'sh bo'lgandagi holat.
///
/// Qaysi matn ko'rsatilishini sahifa hal qiladi — bu widget faqat
/// ko'rsatadi (6.7). "Hali qidirilmagan" va "topilmadi" bir xil ko'rinmasligi
/// kerak, shuning uchun matn tashqaridan beriladi.
final class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key, required this.icon, required this.title, required this.message});

  final String icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h32, vertical: ScreenSize.h40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: ScreenSize.h80,
            width: ScreenSize.h80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              shape: BoxShape.circle,
              border: AppSurface.border(alpha: .8),
            ),
            child: SvgPicture.asset(
              icon,
              height: ScreenSize.h30,
              colorFilter: ColorFilter.mode(AppTheme.colors.grey.withValues(alpha: .7), BlendMode.srcIn),
            ),
          ),

          Gap(ScreenSize.h16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.blackSoft),
          ),

          Gap(ScreenSize.h6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.titleSmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
