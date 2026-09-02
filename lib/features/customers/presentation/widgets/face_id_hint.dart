import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Nima bo'lishini oldindan aytadi: foydalanuvchi kamera nega ochilishini bilsin.
final class FaceIdHint extends StatelessWidget {
  const FaceIdHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenSize.h16),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SvgPicture.asset(
            AppIcons.faceId,
            height: ScreenSize.h28,
            colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
          ),

          Gap(ScreenSize.h12),
          Expanded(
            child: Text(
              "Pasport ma'lumotlarini kiriting, so'ng mijozning yuzini rasmga olasiz. Ma'lumotlar bazadagi rasm bilan solishtiriladi.",
              style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.textBlack, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
