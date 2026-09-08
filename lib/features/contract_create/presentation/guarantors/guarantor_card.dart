import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnomadagi bitta kafil.
final class GuarantorCard extends StatelessWidget {
  const GuarantorCard({super.key, required this.guarantor, required this.isBusy, required this.removePress});

  final ContractGuarantor guarantor;
  final bool isBusy;
  final VoidCallback removePress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h10),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: AppSurface.border(),
      ),
      child: Row(
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

                if (guarantor.passport.isNotEmpty) ...<Widget>[
                  Gap(ScreenSize.h2),
                  Text(guarantor.passport, style: AppTheme.data.textTheme.bodySmall),
                ],
              ],
            ),
          ),

          Gap(ScreenSize.w8),
          if (isBusy)
            SizedBox(
              width: ScreenSize.h34,
              height: ScreenSize.h34,
              child: Center(
                child: SizedBox(
                  width: ScreenSize.h18,
                  height: ScreenSize.h18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
                ),
              ),
            )
          else
            InkWell(
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
            ),
        ],
      ),
    );
  }
}
