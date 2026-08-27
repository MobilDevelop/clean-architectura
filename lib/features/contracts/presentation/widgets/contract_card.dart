import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_status.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/contract_status_style.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_approval_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Shartnoma kartasi.
///
/// Bosilganda nima bo'lishini tashqaridan oladi (6.7).
final class ContractCard extends StatelessWidget {
  const ContractCard({super.key, required this.contract, required this.pressActions});

  final ContractInfo contract;
  final VoidCallback pressActions;

  /// Kartaning chegara rangi diqqat talab qiladigan holatni bildiradi:
  /// KATM tekshiruvi — sariq, imtiyoz — yashil, qolganida oddiy chegara.
  Color? get _accent {
    if (contract.showButtonKATM) return AppTheme.colors.yellow;
    if (contract.hasBenefit) return AppTheme.colors.primary;
    return null;
  }

  bool get _showApprovalNote =>
    contract.status == ContractStatus.allowed &&
    (contract.higherPositionConfirmationRequired || contract.canUserAllowConfirmation);

  @override
  Widget build(BuildContext context) {
    final Color? accent = _accent;
    final Color statusColor = ContractStatusStyle.color(contract.status);

    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: pressActions,
      child: Container(
        margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r20),
          border: accent == null
            ? AppSurface.border()
            : Border.all(color: accent.withValues(alpha: .45), width: ScreenSize.h2),
          boxShadow: AppShadow.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        contract.clientFio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.headlineLarge?.copyWith(
                          color: AppTheme.colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),

                      Gap(ScreenSize.h5),
                      Text(
                        "№ ${contract.id} · ${contract.createdAt}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                Gap(ScreenSize.w6),
                SvgPicture.asset(
                  AppIcons.points,
                  height: ScreenSize.h20,
                  colorFilter: ColorFilter.mode(AppTheme.colors.grey.withValues(alpha: .7), BlendMode.srcIn),
                ),
              ],
            ),

            Gap(ScreenSize.h12),
            Row(
              children: <Widget>[
                _StatusChip(label: ContractStatusStyle.label(contract.status), color: statusColor),

                const Spacer(),
                if (contract.guarantors.isNotEmpty)
                  _MetaChip(icon: AppIcons.person, label: "${contract.guarantors.length} kafil"),

                if (contract.flex) ...<Widget>[
                  Gap(ScreenSize.w6),
                  _MetaChip(icon: AppIcons.card, label: "Flex"),
                ],
              ],
            ),

            if (_showApprovalNote) ContractApprovalNote(contract: contract),
          ],
        ),
      ),
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

final class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h4),
      decoration: BoxDecoration(
        color: AppTheme.colors.backcolor.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: AppSurface.border(alpha: .6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            icon,
            height: ScreenSize.h13,
            colorFilter: ColorFilter.mode(AppTheme.colors.grey, BlendMode.srcIn),
          ),

          Gap(ScreenSize.w5),
          Text(label, style: AppTheme.data.textTheme.labelMedium),
        ],
      ),
    );
  }
}
