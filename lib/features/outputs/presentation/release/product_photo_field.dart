import 'dart:io';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Tovarlar surati: olinmagan bo'lsa taklif, olingan bo'lsa ko'rinishi.
///
/// Kamerani o'zi ochmaydi — bosilganini aytadi (6.7).
final class ProductPhotoField extends StatelessWidget {
  const ProductPhotoField({super.key, required this.photo, required this.errorText, required this.onTap});

  /// `null` — surat hali olinmagan.
  final File? photo;

  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final File? shot = photo;
    final String? error = errorText;
    final bool hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScreenSize.r20),
          child: Container(
            height: ScreenSize.h170,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.colors.backcolor,
              borderRadius: BorderRadius.circular(ScreenSize.r20),
              border: hasError
                  ? Border.all(color: AppTheme.colors.red)
                  : AppSurface.border(),
            ),
            child: shot == null ? _invite() : _preview(shot),
          ),
        ),

        if (hasError) ...<Widget>[
          Gap(ScreenSize.h6),
          Padding(
            padding: EdgeInsets.only(left: ScreenSize.w10),
            child: Text(
              error,
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red),
            ),
          ),
        ],
      ],
    );
  }

  Widget _invite() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          shape: BoxShape.circle,
          boxShadow: AppShadow.card(),
        ),
        child: SvgPicture.asset(
          AppIcons.camera,
          height: ScreenSize.h26,
          colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
        ),
      ),

      Gap(ScreenSize.h10),
      Text(
        ReleaseText.photoTitle,
        style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
      ),

      Gap(ScreenSize.h4),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h20),
        child: Text(
          ReleaseText.photoHint,
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.bodySmall,
        ),
      ),
    ],
  );

  Widget _preview(File shot) => Stack(
    fit: StackFit.expand,
    children: <Widget>[
      ClipRRect(
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        // `cacheWidth` — to'liq o'lchamdagi surat xotirada bir necha o'nlab
        // megabayt egallaydi, ekranda esa u shu kenglikda chiziladi.
        child: Image.file(shot, fit: BoxFit.cover, cacheWidth: 800),
      ),

      Positioned(
        top: ScreenSize.h8,
        right: ScreenSize.h8,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
          decoration: BoxDecoration(
            color: AppTheme.colors.black.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(ScreenSize.r16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(
                AppIcons.camera,
                height: ScreenSize.h14,
                colorFilter: ColorFilter.mode(AppTheme.colors.white, BlendMode.srcIn),
              ),

              Gap(ScreenSize.w6),
              Text(
                ReleaseText.photoChange,
                style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.white),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
