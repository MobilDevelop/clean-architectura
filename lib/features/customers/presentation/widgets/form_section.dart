import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Formadagi bitta bo'lim. Ko'rinishi mijoz kartasi bilan bir xil: oq fon,
/// yumshoq chegara va soya.
final class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.icon, required this.child});

  final String title;
  final String icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ScreenSize.h14),
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: ScreenSize.h32,
                width: ScreenSize.h32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(ScreenSize.r10),
                ),
                child: SvgPicture.asset(
                  icon,
                  height: ScreenSize.h16,
                  colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
                ),
              ),

              Gap(ScreenSize.w10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),
            ],
          ),

          Gap(ScreenSize.h14),
          child,
        ],
      ),
    );
  }
}
