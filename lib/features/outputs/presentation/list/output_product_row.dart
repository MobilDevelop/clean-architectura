import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/presentation/shared/output_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Chiqimdagi bitta tovar.
///
/// Qaytarish rejimida belgilanadi. Belgilanganini o'zi hal qilmaydi —
/// ko'rsatadi (6.7).
final class OutputProductRow extends StatelessWidget {
  const OutputProductRow({
    super.key,
    required this.product,
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
  });

  final OutputProduct product;

  /// Qaytarish mumkin bo'lgan shartnomada tovar belgilanadi.
  final bool isSelectable;

  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget row = Container(
      margin: EdgeInsets.only(top: ScreenSize.h8),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.colors.primary.withValues(alpha: .08) : AppTheme.colors.backcolor,
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: isSelected ? Border.all(color: AppTheme.colors.primary) : AppSurface.border(alpha: .6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (isSelectable) ...<Widget>[
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: ScreenSize.h20,
              color: isSelected ? AppTheme.colors.primary : AppTheme.colors.grey1,
            ),

            Gap(ScreenSize.w10),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Tovar nomi kesilmaydi: bir xil boshlanadigan nomlar
                // («iPhone 15 Pro Max 256GB…») aynan oxiri bilan farq qiladi.
                Text(
                  product.name,
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
                ),

                if (product.category.isNotEmpty) ...<Widget>[
                  Gap(ScreenSize.h2),
                  Text(product.category, style: AppTheme.data.textTheme.bodySmall),
                ],

                // Miqdor va narx nom ostida, alohida qatorda: yonma-yon
                // qo'yilganda uzun nom summani qatordan chiqarib yuborardi.
                Gap(ScreenSize.h6),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: ScreenSize.w10,
                  runSpacing: ScreenSize.h4,
                  children: <Widget>[
                    Text("${product.count} ${OutputText.count}", style: AppTheme.data.textTheme.bodySmall),

                    // Narx serverdan qanday kelsa shunday ko'rsatiladi.
                    // `price * count` deb chiqarish javob boshqacha bo'lsa
                    // summani jimgina ikki barobar ko'rsatardi — backenddan
                    // so'ralgan.
                    Text(
                      Money.withUnit(product.price),
                      style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.black),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!isSelectable) return row;

    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(ScreenSize.r14), child: row);
  }
}
