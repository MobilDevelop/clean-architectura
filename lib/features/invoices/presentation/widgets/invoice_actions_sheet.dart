import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_item.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_sheet.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/presentation/styles/invoice_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Faktura amallari: faylni ochish va ta'minotchiga yuborish.
///
/// Amallarni oynaning o'zi bajarmaydi — chaqiruvchiga aytadi (6.7).
Future<void> showInvoiceActionsSheet({
  required BuildContext context,
  required Invoice invoice,
  required VoidCallback onOpen,
  required VoidCallback onSend,
}) => showActionSheet(
  context: context,
  header: _Header(invoice: invoice),
  actions: <Widget>[
    ActionItem(
      icon: AppIcons.eyeOpen,
      color: AppTheme.colors.blue,
      title: InvoiceText.open,
      subtitle: InvoiceText.openHint,
      enabled: invoice.canOpen,
      onTap: onOpen,
    ),

    ActionItem(
      icon: AppIcons.send,
      color: AppTheme.colors.primary,
      title: InvoiceText.send,
      subtitle: InvoiceText.sendHint,
      enabled: invoice.canSend,
      onTap: onSend,
    ),
  ],
);

final class _Header extends StatelessWidget {
  const _Header({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          InvoiceText.sheetTitle(invoice.contractId),
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h4),
        Text(invoice.partnerName, textAlign: TextAlign.center, style: AppTheme.data.textTheme.titleSmall),

        Gap(ScreenSize.h6),
        Text(
          Money.withUnit(invoice.price),
          style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.primary),
        ),

        // O'chiq amalning sababi tugmaning o'zida ko'rinmaydi, shuning uchun
        // u shu yerda aytiladi (5.8).
        if (!invoice.canOpen) ...<Widget>[
          Gap(ScreenSize.h8),
          Text(
            InvoiceText.noFile,
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red),
          ),
        ],
      ],
    );
  }
}
