import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ikki holatdan bittasini tanlash (ha / yo'q).
///
/// Nega ro'yxat oynasi emas: ikkita variant uchun oyna ochish bitta bosishni
/// uchtaga aylantiradi.
final class BoxChoice extends StatelessWidget {
  const BoxChoice({
    super.key,
    required this.title,
    required this.yesLabel,
    required this.noLabel,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String title;
  final String yesLabel;
  final String noLabel;

  /// `null` — hali tanlanmagan.
  final bool? value;

  final ValueChanged<bool> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final String? error = errorText;
    final bool hasError = error != null;

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
        Row(
          children: <Widget>[
            Expanded(child: _option(label: yesLabel, isOn: value == true, onTap: () => onChanged(true))),

            Gap(ScreenSize.w10),
            Expanded(child: _option(label: noLabel, isOn: value == false, onTap: () => onChanged(false))),
          ],
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

  Widget _option({required String label, required bool isOn, required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ScreenSize.r25),
    child: Container(
      height: ScreenSize.h48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isOn ? AppTheme.colors.primary.withValues(alpha: .10) : AppTheme.colors.backcolor,
        borderRadius: BorderRadius.circular(ScreenSize.r25),
        border: Border.all(color: isOn ? AppTheme.colors.primary : AppTheme.colors.stroke),
      ),
      child: Text(
        label,
        style: AppTheme.data.textTheme.titleSmall?.copyWith(
          color: isOn ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
          fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    ),
  );
}
