import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ekran tepasidagi karta: mijoz, shartnoma raqami va status.
///
/// Umumiy summa bu yerda ko'rsatilmaydi — u tovarlar tabida, tovarlar
/// ro'yxatining ustida turadi va o'sha yerda ma'noga ega.
final class ContractSummaryCard extends StatelessWidget {
  const ContractSummaryCard({
    super.key,
    required this.clientName,
    required this.contractNumber,
    required this.statusLabel,
    required this.statusColor,
  });

  final String clientName;

  /// Shartnoma raqami. Qoralama yo'q bo'lsa bo'sh.
  final String contractNumber;

  /// Status matni. Qoralama yo'q bo'lsa bo'sh.
  final String statusLabel;

  /// Status rangi — u ma'noni bildiradi, shuning uchun tashqaridan keladi (6.7).
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final String initial = clientName.isEmpty ? "?" : clientName.characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h10),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenSize.h40,
            height: ScreenSize.h40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
            ),
          ),

          Gap(ScreenSize.w10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  clientName.isEmpty ? "Mijoz" : clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),

                if (contractNumber.isNotEmpty)
                  Text("Shartnoma № $contractNumber", style: AppTheme.data.textTheme.bodySmall),
              ],
            ),
          ),

          if (statusLabel.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.w8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(ScreenSize.r20),
              ),
              child: Text(
                statusLabel,
                style: AppTheme.data.textTheme.bodySmall?.copyWith(color: statusColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
