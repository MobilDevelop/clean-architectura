import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Daromad bayroqlari — ikkita bosiladigan chip.
///
/// Nega kalit emas: ikkita to'liq kenglikdagi plitka ekranning yaxshigina
/// qismini yeb qo'yardi, holbuki ikkalasi ham ha/yo'q javob. Chip yoqilganda
/// to'ldiriladi — tumblerdan ko'ra ro'yxat ichida yaqqolroq ko'rinadi.
final class IncomeChips extends StatelessWidget {
  const IncomeChips({
    super.key,
    required this.isInformal,
    required this.hasCarIncome,
    required this.lockedReason,
    required this.basisPressed,
    required this.carPressed,
  });

  final bool isInformal;
  final bool hasCarIncome;

  /// Daromad asosini o'zgartirib bo'lmasligining sababi. `null` — mumkin.
  final String? lockedReason;

  final VoidCallback basisPressed;
  final VoidCallback carPressed;

  @override
  Widget build(BuildContext context) {
    final String? reason = lockedReason;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _chip(
                icon: Icons.person_outline_rounded,
                label: "Norasmiy",
                isOn: isInformal,
                onTap: reason == null ? basisPressed : null,
              ),
            ),
            Gap(ScreenSize.w8),
            Expanded(
              child: _chip(
                icon: Icons.directions_car_outlined,
                label: "Avtomobil",
                isOn: hasCarIncome,
                onTap: carPressed,
              ),
            ),
          ],
        ),

        if (reason != null) ...<Widget>[
          Gap(ScreenSize.h6),
          Text(reason, style: AppTheme.data.textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required bool isOn,
    required VoidCallback? onTap,
  }) {
    final bool isLocked = onTap == null;
    final Color tone = isLocked ? AppTheme.colors.grey1 : AppTheme.colors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h10),
        decoration: BoxDecoration(
          color: isOn ? tone.withValues(alpha: .1) : AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r14),
          border: isOn ? Border.all(color: tone.withValues(alpha: .45)) : AppSurface.border(),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              isOn ? Icons.check_circle_rounded : icon,
              size: ScreenSize.h18,
              color: isOn ? tone : AppTheme.colors.grey,
            ),
            Gap(ScreenSize.w8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.titleSmall?.copyWith(
                  color: isOn ? tone : (isLocked ? AppTheme.colors.grey : AppTheme.colors.blackSoft),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
