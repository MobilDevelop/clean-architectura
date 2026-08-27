import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Ism-familiyaning bosh harflaridan yasalgan avatar.
///
/// Nega bosh harflar: mijozning surati yo'q, bir xil ikonka esa butun ro'yxatni
/// bir-biriga o'xshatib yuboradi. Ism bo'sh bo'lsa — ikonkaga qaytadi.
final class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({super.key, required this.fullName, this.size});

  final String fullName;
  final double? size;

  String get _initials {
    final List<String> words = fullName.trim().split(RegExp(r'\s+')).where((String word) => word.isNotEmpty).toList();
    if (words.isEmpty) return '';

    final StringBuffer buffer = StringBuffer(words.first[0]);
    if (words.length > 1) buffer.write(words[1][0]);
    return buffer.toString().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double side = size ?? ScreenSize.h48;
    final String initials = _initials;

    return Container(
      height: side,
      width: side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .18)),
      ),
      child: initials.isEmpty
        ? SvgPicture.asset(
            AppIcons.person,
            height: side / 2,
            colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
          )
        : Text(
            initials,
            style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.primary),
          ),
    );
  }
}
