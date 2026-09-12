import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/drawer/drawer_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Qator o'ng chetida nima turishi.
enum DrawerTileMark {
  /// Ekran tayyor — strelka.
  open,

  /// Ekran hali yozilmagan — «tez orada» belgisi.
  soon,

  /// Amal, boshqa ekranga o'tilmaydi (chiqish) — hech nima.
  none,
}

/// Menyudagi bitta qator.
///
/// Widget qaror qabul qilmaydi (6.7): bo'lim tayyormi, qanday rangda —
/// hammasini chaqiruvchi aytadi.
final class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.mark,
    required this.onTap,
    this.materialIcon,
  });

  final String title;

  /// SVG yo'li. `materialIcon` berilsa ishlatilmaydi.
  final String icon;

  /// Ayrim bo'limlar uchun loyihada SVG yo'q.
  final IconData? materialIcon;

  final Color accent;
  final DrawerTileMark mark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final IconData? material = materialIcon;

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.h8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        child: Container(
          padding: EdgeInsets.all(ScreenSize.h12),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(ScreenSize.r16),
            border: AppSurface.border(alpha: .6),
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: ScreenSize.h36,
                width: ScreenSize.h36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(ScreenSize.r12),
                ),
                child: material != null
                    ? Icon(material, size: ScreenSize.h18, color: accent)
                    : SvgPicture.asset(
                        icon,
                        height: ScreenSize.h18,
                        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                      ),
              ),

              Gap(ScreenSize.w12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(
                    // Tayyor bo'lmagan bo'lim so'nggan ko'rinadi.
                    color: mark == DrawerTileMark.soon
                        ? AppTheme.colors.grey
                        : AppTheme.colors.blackSoft,
                  ),
                ),
              ),

              Gap(ScreenSize.w8),
              switch (mark) {
                DrawerTileMark.open => Icon(
                  Icons.chevron_right_rounded,
                  size: ScreenSize.h20,
                  color: AppTheme.colors.grey,
                ),
                DrawerTileMark.soon => _soonBadge(),
                DrawerTileMark.none => const SizedBox.shrink(),
              },
            ],
          ),
        ),
      ),
    );
  }

  Widget _soonBadge() => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h2),
    decoration: BoxDecoration(
      color: AppTheme.colors.grey.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(ScreenSize.r8),
    ),
    child: Text(
      DrawerText.soon,
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
    ),
  );
}
