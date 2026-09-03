import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ishtirokchi tanlagichi. Bitta ishtirokchi bo'lsa umuman chizilmaydi —
/// tanlanadigan narsa yo'q.
final class ParticipantSelect extends StatelessWidget {
  const ParticipantSelect({
    super.key,
    required this.participants,
    required this.selectedId,
    required this.onSelected,
  });

  final List<CreditParticipant> participants;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (participants.length < 2) return const SizedBox.shrink();

    return SizedBox(
      height: ScreenSize.h44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
        itemCount: participants.length,
        separatorBuilder: (BuildContext context, int index) => Gap(ScreenSize.w8),
        itemBuilder: (BuildContext context, int index) {
          final CreditParticipant item = participants[index];
          final bool isSelected = item.clientId == selectedId;

          return InkWell(
            onTap: () => onSelected(item.clientId),
            borderRadius: BorderRadius.circular(ScreenSize.r14),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14),
              constraints: BoxConstraints(maxWidth: ScreenSize.h200),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.colors.primary : AppTheme.colors.white,
                borderRadius: BorderRadius.circular(ScreenSize.r14),
                border: isSelected ? null : AppSurface.border(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.role == ParticipantRole.client ? "Mijoz" : "Kafil",
                    style: AppTheme.data.textTheme.bodySmall?.copyWith(
                      color: isSelected ? AppTheme.colors.white : AppTheme.colors.grey,
                    ),
                  ),

                  Gap(ScreenSize.w6),
                  Flexible(
                    child: Text(
                      item.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.titleMedium?.copyWith(
                        color: isSelected ? AppTheme.colors.white : AppTheme.colors.blackSoft,
                      ),
                    ),
                  ),

                  // Qarzi yoki ogohlantirishi borligi tanlashdan oldin ko'rinadi.
                  if (item.mib.state == ReportState.hasDebt || item.katm.hasWarning) ...<Widget>[
                    Gap(ScreenSize.w6),
                    Icon(
                      Icons.error_rounded,
                      size: ScreenSize.h16,
                      color: isSelected ? AppTheme.colors.white : AppTheme.colors.red,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
