import 'package:colloborator_v3/core/contract/underwriter_type_text.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/client_identity.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/instruments_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnomadagi bitta kafil: kimligi, daromad hujjatlari va instrumentlari.
final class GuarantorCard extends StatelessWidget {
  const GuarantorCard({
    super.key,
    required this.guarantor,
    required this.isBusy,
    required this.removePress,
    required this.underwriterPress,
    required this.instrumentsPress,
  });

  final ContractGuarantor guarantor;
  final bool isBusy;
  final VoidCallback removePress;
  final VoidCallback underwriterPress;
  final VoidCallback instrumentsPress;

  @override
  Widget build(BuildContext context) {
    final String identity = ClientIdentity.line(passport: guarantor.passport, inps: guarantor.inps);

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h10),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: AppSurface.border(),
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
                      guarantor.fullName.isEmpty ? "Ismi ko'rsatilmagan" : guarantor.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
                    ),

                    if (identity.isNotEmpty) ...<Widget>[
                      Gap(ScreenSize.h2),
                      Text(identity, style: AppTheme.data.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),

              Gap(ScreenSize.w8),
              if (isBusy) _spinner() else _removeButton(),
            ],
          ),

          Gap(ScreenSize.h10),
          Divider(height: ScreenSize.h1, thickness: ScreenSize.h1, color: AppSurface.line()),

          _row(
            label: "Anderrayter",
            value: UnderwriterTypeText.list(guarantor.underwriterTypes),
            action: guarantor.underwriterTypes.isEmpty ? "Kiritish" : "O'zgartirish",
            color: AppTheme.colors.blue,
            onTap: isBusy ? null : underwriterPress,
          ),

          Gap(ScreenSize.h10),
          Divider(height: ScreenSize.h1, thickness: ScreenSize.h1, color: AppSurface.line()),

          _row(
            label: "Instrumentlar",
            value: InstrumentsText.list(guarantor.instrumentTypes),
            action: guarantor.instrumentTypes.isEmpty ? "Tanlash" : "O'zgartirish",
            color: AppTheme.colors.primary,
            onTap: isBusy ? null : instrumentsPress,
          ),
        ],
      ),
    );
  }

  Widget _row({
    required String label,
    required String value,
    required String action,
    required Color color,
    required VoidCallback? onTap,
  }) => Padding(
    padding: EdgeInsets.only(top: ScreenSize.h10),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTheme.data.textTheme.bodySmall),

              Gap(ScreenSize.h2),
              Text(
                value.isEmpty ? InstrumentsText.empty : value,
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
              ),
            ],
          ),
        ),

        Gap(ScreenSize.w8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ScreenSize.r10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: onTap == null ? .03 : .08),
              borderRadius: BorderRadius.circular(ScreenSize.r10),
              border: Border.all(color: color.withValues(alpha: onTap == null ? .12 : .25)),
            ),
            child: Text(
              action,
              style: AppTheme.data.textTheme.bodySmall?.copyWith(
                color: color.withValues(alpha: onTap == null ? .4 : 1),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _spinner() => SizedBox(
    width: ScreenSize.h34,
    height: ScreenSize.h34,
    child: Center(
      child: SizedBox(
        width: ScreenSize.h18,
        height: ScreenSize.h18,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
      ),
    ),
  );

  Widget _removeButton() => InkWell(
    onTap: removePress,
    borderRadius: BorderRadius.circular(ScreenSize.r12),
    child: Container(
      width: ScreenSize.h34,
      height: ScreenSize.h34,
      decoration: BoxDecoration(
        color: AppTheme.colors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
      ),
      child: Icon(Icons.delete_outline, size: ScreenSize.h18, color: AppTheme.colors.red),
    ),
  );
}
