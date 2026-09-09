import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/features/underwriter/presentation/styles/underwriter_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bo'lim tanlagich.
///
/// Ko'rinadigan bo'limlar tashqaridan keladi — qaysi biri ochilishini widget
/// hisoblamaydi (6.7).
final class SectionTabs extends StatelessWidget {
  const SectionTabs({
    super.key,
    required this.sections,
    required this.current,
    required this.isLocked,
    required this.onSelected,
  });

  final List<UnderwriterKind> sections;
  final UnderwriterKind current;

  /// Saqlash ketayotganda bo'lim almashtirilmaydi.
  final bool isLocked;

  final ValueChanged<UnderwriterKind> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenSize.h44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        itemCount: sections.length,
        separatorBuilder: (BuildContext context, int index) => Gap(ScreenSize.w8),
        itemBuilder: (BuildContext context, int index) {
          final UnderwriterKind kind = sections[index];
          final bool isOn = kind == current;
          final Color tone = UnderwriterText.color(kind);

          return InkWell(
            onTap: isLocked || isOn ? null : () => onSelected(kind),
            borderRadius: BorderRadius.circular(ScreenSize.r14),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
              decoration: BoxDecoration(
                color: isOn ? tone.withValues(alpha: .12) : AppTheme.colors.white,
                borderRadius: BorderRadius.circular(ScreenSize.r14),
                border: isOn ? Border.all(color: tone.withValues(alpha: .45)) : AppSurface.border(),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    UnderwriterText.icon(kind),
                    size: ScreenSize.h18,
                    color: isOn ? tone : AppTheme.colors.grey,
                  ),
                  Gap(ScreenSize.w6),
                  Text(
                    UnderwriterText.title(kind),
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: isOn ? tone : AppTheme.colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
