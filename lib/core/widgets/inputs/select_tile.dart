import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ro'yxatdan tanlanadigan maydon. Tanlanmagan bo'lsa `value` bo'sh bo'ladi.
final class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onTap,
    this.errorText,
    this.subtitle,
    this.enabled = true,
  });

  final String title;
  final String hint;
  final String value;
  final VoidCallback onTap;
  final String? errorText;

  /// Qiymat ostidagi qo'shimcha satr — masalan ish joyining faoliyat turi.
  final String? subtitle;

  /// Yuqoridagi maydon tanlanmagan bo'lsa o'chiq turadi.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;
    final bool hasError = error != null;
    final bool isEmpty = value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: ScreenSize.w5),
          child: Text(
            title,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(
              color: hasError ? AppTheme.colors.red : AppTheme.colors.blackSoft,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        Gap(ScreenSize.h5),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(ScreenSize.r25),
          child: Container(
            constraints: BoxConstraints(minHeight: ScreenSize.h48),
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h6),
            decoration: BoxDecoration(
              color: enabled ? AppTheme.colors.backcolor : AppTheme.colors.btnBackcolor,
              borderRadius: BorderRadius.circular(ScreenSize.r25),
              border: Border.all(
                color: hasError
                    ? AppTheme.colors.red
                    : enabled
                    ? AppSurface.line()
                    : AppTheme.colors.grey1,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isEmpty ? hint : value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.titleSmall?.copyWith(
                          color: isEmpty ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                          fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w500,
                        ),
                      ),

                      if (!isEmpty && (subtitle?.isNotEmpty ?? false))
                        Text(
                          subtitle ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.data.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),

                Icon(
                  Icons.expand_more_rounded,
                  color: enabled ? AppTheme.colors.grey : AppTheme.colors.grey1,
                  size: ScreenSize.h22,
                ),
              ],
            ),
          ),
        ),

        if (hasError)
          Padding(
            padding: EdgeInsets.only(left: ScreenSize.w12, top: ScreenSize.h4),
            child: Text(error, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
          ),
      ],
    );
  }
}
