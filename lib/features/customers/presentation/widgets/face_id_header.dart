import 'dart:ui';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/circle_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

final class FaceIdHeader extends StatelessWidget {
  const FaceIdHeader({super.key, required this.topInset, required this.backPress});

  final double topInset;
  final VoidCallback backPress;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: AppSurface.blurSigma, sigmaY: AppSurface.blurSigma),
        child: Container(
          padding: EdgeInsets.only(top: topInset, left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h8),
          decoration: BoxDecoration(
            color: AppTheme.colors.backcolor.withValues(alpha: AppSurface.panelAlpha),
            border: Border(bottom: BorderSide(color: AppSurface.line(alpha: .6))),
          ),
          child: SizedBox(
            height: ScreenSize.h48,
            child: Row(
              children: <Widget>[
                CircleIconButton(icon: AppIcons.arrowBack, onTap: backPress),

                Gap(ScreenSize.w12),
                Expanded(
                  child: Text(
                    "Mijozni tekshirish",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
