import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';

final class MainButton extends StatelessWidget {
  const MainButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.showLoading = false,
    this.margin,
    this.leftIcon,  
    this.color,  
    this.textColor, 
    this.height, 
    this.style,
    this.borderRadius, this.borderColor,
  });

  final String text;
  final String? leftIcon;
  final VoidCallback onPressed;
  final bool showLoading;
  final EdgeInsets? margin;
  final TextStyle? style;
  final Color? color;
  final double? height;
  final double? borderRadius;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    Widget current;

    // Ochiq maydon `null` tekshiruvidan keyin ko'tarilmaydi — mahalliy nusxa
    // `!` operatorisiz ishlashga imkon beradi (12-bo'lim).
    final String? icon = leftIcon;

    if (showLoading) {
      current = Lottie.asset(AppIcons.loading,height: ScreenSize.h45,delegates: LottieDelegates(values: [ValueDelegate.colorFilter(const ['**'],value: ColorFilter.mode(textColor ?? AppTheme.colors.white,BlendMode.srcIn))]));
    } else if (icon != null) {
      current = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon,colorFilter: ColorFilter.mode(textColor ?? AppTheme.colors.white, BlendMode.srcIn)),
          
          Gap(ScreenSize.w10),
          Text(text,style: style ?? AppTheme.data.textTheme.titleLarge?.copyWith(color: textColor?? AppTheme.colors.white))
        ],
      );
    } else {
      current = Text(text,style: style ?? AppTheme.data.textTheme.titleLarge?.copyWith(color: textColor?? AppTheme.colors.white),
      );
    }

    return Bounce(
      onTap: !showLoading && color != AppTheme.colors.grey ?onPressed:(){},
      duration: Duration(milliseconds:250),
      scaleFactor: (color == AppTheme.colors.grey || showLoading)?1:0.96,
      tilt: (color == AppTheme.colors.grey || showLoading)?false:true,
      child: Container(
        width:  double.maxFinite,
        height: height??ScreenSize.h45,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.w15,vertical: showLoading?0:ScreenSize.h8),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius ?? ScreenSize.r25),
          color: color ?? AppTheme.colors.primary,
        ),
        margin: margin,
        child: current,
      ),
    );
  }
}