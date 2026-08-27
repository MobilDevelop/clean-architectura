
// ignore_for_file: deprecated_member_use

import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';


class BorderButton extends StatelessWidget {
  const BorderButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon, this.radius, this.color,
  });

  final VoidCallback onPressed;
  final String text;
  final String? icon;
  final double? radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    Widget current = Text(text,
      maxLines: 1,overflow: TextOverflow.ellipsis,
      style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: color ?? AppTheme.colors.blue),
    );
    if (icon != null) {
      current = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gap(ScreenSize.h7),
          SvgPicture.asset(icon!,color: color ?? AppTheme.colors.blue,height: ScreenSize.h20),

          Gap(ScreenSize.h5),
          Expanded(child: current),
        ],
      );
    }
    return Bounce(
      onTap: onPressed,
      duration: const Duration(milliseconds: 150),
      child: Container(
        height: ScreenSize.h45,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: icon != null ? ScreenSize.h2 : ScreenSize.h10,vertical: ScreenSize.h5),
        decoration: BoxDecoration(
          color: AppTheme.colors.background,
          borderRadius: BorderRadius.circular(radius ?? ScreenSize.r25),
          border: Border.all(color: AppTheme.colors.stroke, width: 1)),
        alignment: Alignment.center,
        child: current,
      ),
    );
  }
}
