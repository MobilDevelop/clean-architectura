import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/contract/contract_status_style.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_row.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_approval_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Shartnoma kartasi.
///
/// Tuzilishi Figma maketidan: yuqorida mijoz, ostida chiziq bilan ajratilgan
/// «yorliq — qiymat» qatorlari. Ilgari ma'lumot ixcham joylashtirilgan edi va
/// qaysi raqam nima ekanini bilish uchun kartani o'qib chiqish kerak bo'lardi;
/// qatorlarda esa ko'z bitta ustundan pastga yuguradi.
///
/// Bosilganda nima bo'lishini tashqaridan oladi (6.7).
final class ContractCard extends StatelessWidget {
  const ContractCard({super.key, required this.contract, required this.pressActions});

  final ContractInfo contract;
  final VoidCallback pressActions;

  /// Kartaning chegara rangi diqqat talab qiladigan holatni bildiradi:
  /// KATM tekshiruvi — sariq, imtiyoz — yashil, qolganida oddiy chegara.
  ///
  /// Maketda bunday belgi yo'q — u ilovaga xos, chunki xodim ro'yxatdan
  /// aynan shu ikki holatni izlaydi.
  Color? get _accent {
    if (contract.showButtonKATM) return AppTheme.colors.yellow;
    if (contract.hasBenefit) return AppTheme.colors.primary;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Color? accent = _accent;

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
            _client(),

            LabeledRow(label: "Shartnoma kodi", value: Text(
              "№ ${contract.id}",
              style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
            )),

            LabeledRow(label: "Sanasi", value: Text(
              contract.createdAt,
              style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
            )),

            // Qo'shimcha qatorlar faqat ma'lumot bo'lganda chiqadi: bo'sh
            // «0 kafil» qatori kartani uzaytirib, hech nima aytmasdi.
            if (contract.guarantors.isNotEmpty)
              LabeledRow(label: "Kafillar", value: Text(
                "${contract.guarantors.length} ta",
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
              )),

            if (contract.flex)
              LabeledRow(label: "Turi", value: Text(
                "Flex",
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
              )),

            LabeledRow(
              label: "Status",
              isLast: true,
              value: _StatusChip(
                label: ContractStatusStyle.label(contract.status),
                color: ContractStatusStyle.color(contract.status),
              ),
            ),

            if (contract.needsApproval) ContractApprovalNote(contract: contract),
          ],
        ),
      ),
    );
  }

  Widget _client() => Row(
    children: <Widget>[
      Container(
        height: ScreenSize.h44,
        width: ScreenSize.h44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.colors.grey1),
        ),
        child: SvgPicture.asset(
          AppIcons.person,
          height: ScreenSize.h20,
          colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
        ),
      ),

      Gap(ScreenSize.w12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Mijozning F.I.O si:",
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey),
            ),

            // Ism kesilmaydi: uzun familiya uch qatorga chiqsa ham to'liq
            // ko'rinadi. Kesilgan ism xodimga mijozni tanishga xalaqit beradi.
            Text(
              contract.clientFio,
              style: AppTheme.data.textTheme.headlineLarge?.copyWith(
                color: AppTheme.colors.black,
                letterSpacing: -0.2,
              ),
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
  );
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(ScreenSize.r10),
      ),
      child: Text(label, style: AppTheme.data.textTheme.titleLarge?.copyWith(color: color)),
    );
  }
}
