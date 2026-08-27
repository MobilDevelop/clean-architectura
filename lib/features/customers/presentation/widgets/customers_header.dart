import 'dart:ui';

import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/widgets/buttons/circle_icon_button.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/customer_search_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Suzuvchi sarlavha: ro'yxat uning ostidan o'tadi va xiralashadi.
final class CustomersHeader extends StatelessWidget {
  const CustomersHeader({
    super.key,
    required this.topInset,
    required this.showSearch,
    required this.searchError,
    required this.controller,
    required this.drawerPress,
    required this.searchPress,
    required this.onChanged,
    required this.onSubmitted,
  });

  final double topInset;
  final bool showSearch;

  /// Kiritish xatosi. Bo'sh bo'lsa maydon tagida hech nima chiqmaydi.
  final String searchError;

  final TextEditingController controller;
  final VoidCallback drawerPress;
  final VoidCallback searchPress;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

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
          child: Column(
            children: <Widget>[
              SizedBox(
                height: ScreenSize.h48,
                child: Row(
                  children: <Widget>[
                    CircleIconButton(icon: AppIcons.drawer, onTap: drawerPress),

                    const Spacer(),
                    Text(
                      "ISHONCH",
                      style: AppTheme.data.textTheme.displayLarge?.copyWith(
                        color: AppTheme.colors.primary,
                        fontSize: ScreenSize.sp22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const Spacer(),
                    CircleIconButton(icon: showSearch ? AppIcons.close : AppIcons.search, onTap: searchPress),
                  ],
                ),
              ),

              AnimatedSize(
                duration: Duration(milliseconds: AppConstants.duration),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: showSearch
                  ? Padding(
                      padding: EdgeInsets.only(top: ScreenSize.h10),
                      child: TextInputWidget(
                        controller: controller,
                        hint: "Mijoz qidirish",
                        // Qidiruv ochilganda klaviatura ham ochiladi — bu ekranda
                        // qidiruvdan boshqa kiritish maydoni yo'q.
                        autoFocus: true,
                        backColor: AppTheme.colors.white,
                        // Kiritish xatosi shu yerda — server xatosi esa toastda (7.5).
                        errorText: searchError.isEmpty ? null : searchError,
                        formatters: <TextInputFormatter>[CustomerSearchFormatter(), LengthLimitingTextInputFormatter(60)],
                        onChanged: onChanged,
                        onSubmitted: onSubmitted,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
