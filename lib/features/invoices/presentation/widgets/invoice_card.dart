import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/contract/contract_status_style.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_row.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/presentation/styles/invoice_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Faktura kartasi. Bosilganda amallar oynasi ochiladi.
///
/// Tuzilishi shartnoma kartasi bilan bir xil: yuqorida tashkilot, ostida
/// chiziq bilan ajratilgan «yorliq — qiymat» qatorlari.
final class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key, required this.invoice, required this.isSending, required this.onTap});

  final Invoice invoice;

  /// Shu faktura ta'minotchiga yuborilmoqda.
  final bool isSending;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r20),
          border: AppSurface.border(),
          boxShadow: AppShadow.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _partner(),

            LabeledRow(
              label: InvoiceText.amount,
              value: Text(
                Money.withUnit(invoice.price),
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.primary),
              ),
            ),

            LabeledRow(
              label: InvoiceText.contract,
              value: Text(
                "№ ${invoice.contractId}",
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
              ),
            ),

            LabeledRow(
              label: InvoiceText.status,
              isLast: true,
              value: _StatusChip(
                label: ContractStatusStyle.label(invoice.status),
                color: ContractStatusStyle.color(invoice.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _partner() => Row(
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
          AppIcons.workplace,
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
              InvoiceText.partner,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey),
            ),

            // Tashkilot nomi kesilmaydi: uzun nomlar aynan oxiri bilan farq
            // qiladi («… MChJ», «… XK»).
            Text(
              invoice.partnerName,
              style: AppTheme.data.textTheme.headlineLarge?.copyWith(
                color: AppTheme.colors.black,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),

      Gap(ScreenSize.w6),
      // Yuborish davom etayotgani aynan shu kartada ko'rinadi.
      if (isSending)
        SizedBox(
          height: ScreenSize.h20,
          width: ScreenSize.h20,
          child: CircularProgressIndicator(color: AppTheme.colors.primary, strokeWidth: ScreenSize.h2),
        )
      else
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
