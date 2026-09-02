import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Oferta tasdig'i. Belgilanmagan bo'lsa bosilganda matn ochiladi,
/// belgilangan bo'lsa bekor qiladi.
final class OfferCheck extends StatelessWidget {
  const OfferCheck({super.key, required this.isAccepted, required this.onOpen, required this.onCancel});

  final bool isAccepted;
  final VoidCallback onOpen;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isAccepted ? onCancel : onOpen,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h10),
        decoration: BoxDecoration(
          color: isAccepted ? AppTheme.colors.primary.withValues(alpha: .08) : AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r18),
          border: isAccepted ? Border.all(color: AppTheme.colors.primary.withValues(alpha: .35)) : AppSurface.border(),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              isAccepted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isAccepted ? AppTheme.colors.primary : AppTheme.colors.grey1,
              size: ScreenSize.h24,
            ),

            Gap(ScreenSize.w10),
            Expanded(
              child: Text(
                isAccepted ? "Ommaviy oferta shartlari bilan tanishdim" : "Ommaviy oferta shartlarini o'qish",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(
                  color: isAccepted ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
                ),
              ),
            ),

            if (!isAccepted) Icon(Icons.chevron_right_rounded, color: AppTheme.colors.grey, size: ScreenSize.h22),
          ],
        ),
      ),
    );
  }
}
