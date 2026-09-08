import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Kam ishlatiladigan ekranga kirish qatori.
///
/// O'z ramkasi yo'q — u bo'lim ramkasi ichida turadi va qo'shnilaridan
/// ingichka chiziq bilan ajraladi. Rangli ikonka esa qatorlarni bir-biridan
/// ajratadigan asosiy belgi: matnni o'qimasdan ham qaysi qator nima ekani
/// ko'rinadi.
final class ExtraEntryRow extends StatelessWidget {
  const ExtraEntryRow({
    super.key,
    required this.title,
    required this.hint,
    required this.icon,
    required this.accent,
    required this.blockReason,
    required this.onTap,
  });

  final String title;

  /// Ekran nima qilishini aytadigan qisqa satr.
  final String hint;

  final IconData icon;

  /// Qatorning ma'nosini bildiruvchi rang.
  final Color accent;

  /// Nega ochib bo'lmaydi. `null` bo'lsa ochiladi.
  final String? blockReason;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? reason = blockReason;
    final bool isBlocked = reason != null;

    // Bloklangan qatorda rang so'nadi: u hali ishlamaydi, lekin joyida turadi.
    final Color tone = isBlocked ? AppTheme.colors.grey1 : accent;

    return InkWell(
      // Bosilmaydi, lekin sababi ko'rinib turadi (5.8).
      onTap: isBlocked ? null : onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h10),
        child: Row(
          children: <Widget>[
            Container(
              width: ScreenSize.h36,
              height: ScreenSize.h36,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: isBlocked ? .07 : .12),
                borderRadius: BorderRadius.circular(ScreenSize.r12),
              ),
              child: Icon(icon, size: ScreenSize.h18, color: tone),
            ),

            Gap(ScreenSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: isBlocked ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                    ),
                  ),
                  Gap(ScreenSize.h2),
                  Text(
                    reason ?? hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.bodySmall?.copyWith(
                      color: isBlocked ? AppTheme.colors.yellow : null,
                    ),
                  ),
                ],
              ),
            ),

            Gap(ScreenSize.w8),
            Icon(
              Icons.chevron_right,
              size: ScreenSize.h20,
              color: isBlocked ? AppTheme.colors.grey1 : AppTheme.colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
