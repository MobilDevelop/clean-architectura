import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Pastki menyuning bitta bandi. Tanlanganini o'zi hal qilmaydi — ko'rsatadi.
final class BottomItem extends StatelessWidget {
  const BottomItem({super.key, required this.icon, required this.label, required this.isSelect, required this.press});

  final String icon;
  final String label;
  final bool isSelect;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelect ? AppTheme.colors.primary : AppTheme.colors.textGraySoft;

    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: press,
      child: ColoredBox(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(milliseconds: AppConstants.duration),
              curve: Curves.easeOutCubic,
              height: ScreenSize.h34,
              width: isSelect ? ScreenSize.h58 : ScreenSize.h44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelect ? AppTheme.colors.primary.withValues(alpha: .12) : Colors.transparent,
                borderRadius: BorderRadius.circular(ScreenSize.r18),
              ),
              child: SvgPicture.asset(
                icon,
                height: ScreenSize.h23,
                width: ScreenSize.h23,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),

            Gap(ScreenSize.h1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Panel balandligi qat'iy (80px), shuning uchun yozuv
              // cheksiz kattalasha olmaydi: tizim shrifti 1.3× bo'lganda u
              // paneldan toshib ketardi. Chegara 1.1 — kattalashtirish
              // butunlay o'chirilmaydi, faqat panelga sig'adigan darajada.
              textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1),
              // Pastki navigatsiya yozuvi dizaynda 13px (`labelSmall`) —
              // `bodySmall` (14) bu yerda panelning qat'iy balandligiga
              // siqilardi.
              style: AppTheme.data.textTheme.labelSmall?.copyWith(color: color, fontWeight: isSelect ? FontWeight.w600 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
