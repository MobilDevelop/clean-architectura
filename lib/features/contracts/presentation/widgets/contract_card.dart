import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/contract/contract_status_style.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/client_identity.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_cell_row.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_row.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_approval_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Shartnoma kartasi. Balandligi o'lchangan va testda qulflangan
/// (`contract_card_fit_test.dart`) — yangi qator qo'shishdan oldin shu test
/// ko'riladi.
///
/// Status `LabeledRow` da: uning qiymati eng uzun matn va yarim enda
/// bo'linib ketardi.
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
          border: accent == null ? AppSurface.border() : Border.all(color: accent.withValues(alpha: .45), width: ScreenSize.h2),
          boxShadow: AppShadow.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _flags(),
            _client(),

            LabeledCellRow(
              cells: <LabeledCell>[
                LabeledCell(label: "Shartnoma kodi", value: _value("№ ${contract.id}")),
                LabeledCell(label: "Sanasi", value: _value(contract.createdAt)),
              ],
            ),

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

  /// Ramka rangining ma'nosi. Ikkalasi birga bo'lsa ikkita yozuv chiqadi —
  /// ramka esa faqat bitta rangda bo'la oladi.
  Widget _flags() {
    final List<Widget> flags = <Widget>[
      if (contract.showButtonKATM)
        _Flag(color: AppTheme.colors.yellow, label: "KATM/MIB tekshiruvidan o'tmadi"),

      if (contract.hasBenefit) _Flag(color: AppTheme.colors.primary, label: "Imtiyozli shartnoma"),
    ];

    if (flags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.h10),
      child: Wrap(spacing: ScreenSize.w6, runSpacing: ScreenSize.h6, children: flags),
    );
  }

  Widget _value(String text) => Text(
    text,
    style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
  );

  // `start`: ism uzun bo'lib bir necha qatorga chiqqanda avatar va menyu
  // butun blok balandligining o'rtasiga emas, yorliq bilan bir qatorga
  // tortilib qolmasligi kerak.
  Widget _client() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
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
            // Ism kesilmaydi: uzun familiya uch qatorga chiqsa ham to'liq
            // ko'rinadi. Kesilgan ism xodimga mijozni tanishga xalaqit beradi.
            Text(contract.clientFio,style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black,letterSpacing: -0.2)),

            if (_identity.isNotEmpty) ...<Widget>[
              Gap(ScreenSize.h2),
              Text(_identity, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey)),
            ],
          ],
        ),
      ),
    ],
  );

  String get _identity => ClientIdentity.line(passport: contract.passport, inps: contract.inps);
}

/// Nuqta ramka bilan bir rangda — ko'z ularni bog'laydi.
final class _Flag extends StatelessWidget {
  const _Flag({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(ScreenSize.r10),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: ScreenSize.h6,
            height: ScreenSize.h6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          Gap(ScreenSize.w6),
          Text(label, style: AppTheme.data.textTheme.bodySmall?.copyWith(color: color)),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(ScreenSize.r10),
      ),
      child: Text(label, style: AppTheme.data.textTheme.titleLarge?.copyWith(color: color)),
    );
  }
}
