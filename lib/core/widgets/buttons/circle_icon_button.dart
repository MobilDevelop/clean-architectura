import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Sarlavhalardagi dumaloq ikonka tugmasi.
final class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, required this.onTap, this.color});

  final String icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: onTap,
      child: Container(
        // Nega 44: bundan kichik tugmaga barmoq bilan aniq tegib bo'lmaydi —
        // iOS va Android ikkalasi ham shu o'lchamni eng kichik chegara deb beradi.
        height: ScreenSize.h44,
        width: ScreenSize.h44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          shape: BoxShape.circle,
          border: AppSurface.border(),
          boxShadow: AppShadow.card(),
        ),
        child: SvgPicture.asset(
          icon,
          height: ScreenSize.h18,
          width: ScreenSize.h18,
          colorFilter: ColorFilter.mode(color ?? AppTheme.colors.blackSoft, BlendMode.srcIn),
        ),
      ),
    );
  }
}
