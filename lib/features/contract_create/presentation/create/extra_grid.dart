import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_extra_style.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// «Qo'shimcha» qatorlarini ikki ustunli katakchalarda ko'rsatadi.
///
/// Nega katak, to'liq qator emas: beshtagacha qator har biri o'z sarlavhasi
/// bilan «Shartnoma» tabini sezilarli uzaytirardi (`terms_tab_fit_test.dart`
/// buni o'lchab qulflaydi). Ikonka + amal belgisi (badge) — v3'ning boshqa
/// kartalarida ishlatiladigan oq karta + ingichka chegara qolipi bilan bir
/// xil (`AppSurface.border`).
final class ExtraGrid extends StatelessWidget {
  const ExtraGrid({super.key, required this.rows, required this.onTap});

  final List<ContractExtraRow> rows;
  final ValueChanged<ContractExtra> onTap;

  @override
  Widget build(BuildContext context) {
    final List<Widget> lines = <Widget>[];

    for (int i = 0; i < rows.length; i += 2) {
      final bool hasPair = i + 1 < rows.length;

      if (i > 0) lines.add(Gap(ScreenSize.h10));

      // Toq sondagi oxirgi element yarim bo'sh joy qoldirmasin — o'z
      // qatorida, gorizontal joylashuvda, butun kenglikni egallaydi.
      // Ikkinchi ustunni bo'sh `Expanded` bilan to'ldirish qatorni
      // nomutanosib va bo'sh ko'rsatardi.
      if (!hasPair) {
        lines.add(_wideTile(rows[i]));
        continue;
      }

      // `IntrinsicHeight` + `stretch`: juftlikdagi ikkala katak bir xil
      // balandlikda turadi (biri bloklanib, izoh qatori qo'shilganda ham).
      // Buni cheklamasdan qo'ysa, `Row` cheksiz balandlikka cho'ziladi
      // (`ListView` ichida asosiy o'q chegarasiz beriladi).
      lines.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: _gridTile(rows[i])),
              Gap(ScreenSize.w10),
              Expanded(child: _gridTile(rows[i + 1])),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(ScreenSize.h14, 0, ScreenSize.h14, ScreenSize.h12),
      child: Column(children: lines),
    );
  }

  Widget _gridTile(ContractExtraRow row) => _ExtraGridTile(
    title: ContractExtraStyle.title(row.extra),
    action: ContractExtraStyle.action(row.extra),
    icon: ContractExtraStyle.icon(row.extra),
    accent: ContractExtraStyle.color(row.extra),
    blockReason: ContractExtraStyle.block(row.block),
    onTap: () => onTap(row.extra),
  );

  Widget _wideTile(ContractExtraRow row) => _ExtraWideTile(
    title: ContractExtraStyle.title(row.extra),
    action: ContractExtraStyle.action(row.extra),
    icon: ContractExtraStyle.icon(row.extra),
    accent: ContractExtraStyle.color(row.extra),
    blockReason: ContractExtraStyle.block(row.block),
    onTap: () => onTap(row.extra),
  );
}

/// Ikonka aylana ichida — ikkala katak turi ham shu bilan boshlanadi.
final class _ExtraIcon extends StatelessWidget {
  const _ExtraIcon({required this.icon, required this.tone, required this.isBlocked});

  final IconData icon;
  final Color tone;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) => Container(
    width: ScreenSize.h36,
    height: ScreenSize.h36,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: tone.withValues(alpha: isBlocked ? .06 : .12), shape: BoxShape.circle),
    child: Icon(icon, size: ScreenSize.h18, color: tone),
  );
}

/// Amalning qisqa nomi (masalan "Ko'rish", "Kiritish") — kapsula ichida.
final class _ExtraBadge extends StatelessWidget {
  const _ExtraBadge({required this.text, required this.tone, required this.isBlocked});

  final String text;
  final Color tone;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h3),
    decoration: BoxDecoration(
      color: tone.withValues(alpha: isBlocked ? .06 : .12),
      borderRadius: BorderRadius.circular(ScreenSize.r20),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: tone, fontWeight: FontWeight.w600),
    ),
  );
}

/// Ikki ustunli katak: ikonka + badge tepada, sarlavha ostida. Tor joyga
/// mo'ljallangan — shuning uchun vertikal.
final class _ExtraGridTile extends StatelessWidget {
  const _ExtraGridTile({
    required this.title,
    required this.action,
    required this.icon,
    required this.accent,
    required this.blockReason,
    required this.onTap,
  });

  final String title;
  final String action;
  final IconData icon;
  final Color accent;
  final String? blockReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? reason = blockReason;
    final bool isBlocked = reason != null;

    // Bloklangan katakda rang so'nadi: u hali ishlamaydi, lekin joyida turadi.
    final Color tone = isBlocked ? AppTheme.colors.grey1 : accent;

    return InkWell(
      onTap: isBlocked ? null : onTap,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      child: Container(
        padding: EdgeInsets.all(ScreenSize.h12),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r18),
          border: AppSurface.border(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _ExtraIcon(icon: icon, tone: tone, isBlocked: isBlocked),

                Gap(ScreenSize.w6),
                // `Flexible`: uzun amal so'zi (masalan "O'tkazish") tor
                // katakda `Row`ni toshirmasin — sig'masa o'zi qisqaradi.
                Flexible(child: _ExtraBadge(text: action, tone: tone, isBlocked: isBlocked)),
              ],
            ),

            Gap(ScreenSize.h10),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(
                color: isBlocked ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Sabab faqat bloklanganda ko'rinadi: ochiq katakda joy ham
            // keraksiz — sarlavha va rang yetarli (7.5 dagi kabi,
            // kamchilik faqat kerak bo'lganda ko'rsatiladi).
            if (isBlocked) ...<Widget>[
              Gap(ScreenSize.h2),
              Text(
                reason,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.yellow),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Toq sondagi oxirgi element uchun: butun kenglikda, gorizontal joylashuv —
/// ikonka, sarlavha (o'rtada) va badge bitta qatorda. Ikki ustunli katakni
/// shunchaki ikki barobar kengaytirish bo'sh joy qoldirardi.
final class _ExtraWideTile extends StatelessWidget {
  const _ExtraWideTile({
    required this.title,
    required this.action,
    required this.icon,
    required this.accent,
    required this.blockReason,
    required this.onTap,
  });

  final String title;
  final String action;
  final IconData icon;
  final Color accent;
  final String? blockReason;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? reason = blockReason;
    final bool isBlocked = reason != null;
    final Color tone = isBlocked ? AppTheme.colors.grey1 : accent;

    return InkWell(
      onTap: isBlocked ? null : onTap,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      child: Container(
        padding: EdgeInsets.all(ScreenSize.h12),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r18),
          border: AppSurface.border(),
        ),
        child: Row(
          children: <Widget>[
            _ExtraIcon(icon: icon, tone: tone, isBlocked: isBlocked),

            Gap(ScreenSize.w12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: isBlocked ? AppTheme.colors.grey : AppTheme.colors.blackSoft,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (isBlocked)
                    Text(
                      reason,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.yellow),
                    ),
                ],
              ),
            ),

            Gap(ScreenSize.w8),
            _ExtraBadge(text: action, tone: tone, isBlocked: isBlocked),
          ],
        ),
      ),
    );
  }
}
