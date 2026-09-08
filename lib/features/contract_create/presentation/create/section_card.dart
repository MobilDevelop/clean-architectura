import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bo'lim ramkasi: rangli sarlavha va uning ostidagi qatorlar.
///
/// Nega bitta ramka: har bir qator o'z chegarasiga ega bo'lsa, ekran
/// bir-biriga o'xshash qutilar to'plamiga aylanadi va qaysi qator qaysi
/// bo'limga tegishli ekani ko'rinmaydi. Ramka ichidagi qatorlar esa faqat
/// ingichka chiziq bilan ajratiladi.
final class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.children,
    this.isDivided = true,
  });

  final String title;
  final IconData icon;

  /// Bo'limning ma'nosini bildiruvchi rang.
  final Color accent;

  /// Qatorlar orasiga ajratuvchi chiziq qo'yiladimi. Boshqaruv elementlari
  /// (chiplar, maydonlar) uchun kerak emas.
  final bool isDivided;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(ScreenSize.h14, ScreenSize.h12, ScreenSize.h14, ScreenSize.h8),
            child: Row(
              children: <Widget>[
                Icon(icon, size: ScreenSize.h18, color: accent),
                Gap(ScreenSize.w8),
                Text(
                  title,
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ],
            ),
          ),

          ..._body(),
          Gap(ScreenSize.h6),
        ],
      ),
    );
  }

  List<Widget> _body() {
    final List<Widget> out = <Widget>[];

    for (int i = 0; i < children.length; i++) {
      if (isDivided && i > 0) {
        out.add(
          Padding(
            // Chiziq matn boshiga tekislanadi — ikonka ustidan o'tmaydi.
            padding: EdgeInsets.only(left: ScreenSize.h62),
            child: Divider(height: 1, thickness: 1, color: AppSurface.line(alpha: .5)),
          ),
        );
      }

      out.add(children[i]);
    }

    return out;
  }
}
