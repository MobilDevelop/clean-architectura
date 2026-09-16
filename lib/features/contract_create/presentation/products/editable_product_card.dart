import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/imei_list.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnoma tuzishdagi tovar qatori: tahrirlash va o'chirish bilan.
///
/// Ko'rish ekranidagi `ContractProductCard` dan alohida — u amalsiz va shu
/// sababli shartsiz. Ikkalasini bitta widgetga qo'shish qaror qabul qiladigan
final class EditableProductCard extends StatelessWidget {
  const EditableProductCard({
    super.key,
    required this.product,
    required this.isBusy,
    required this.editPress,
    required this.removePress,
  });

  final ContractProduct product;

  /// Shu qator ustida server amali ketyapti.
  final bool isBusy;

  final VoidCallback editPress;
  final VoidCallback removePress;

  /// Sarlavhada tovarning o'z nomi turadi, bu qatorda esa u qanday tovar
  /// ekani: toifa va brend.
  String get _kind => <String>[
    if (!product.variant.isEmpty) product.category.name,
    product.brand.name,
  ].where((String e) => e.isNotEmpty).join(' · ');

  @override
  Widget build(BuildContext context) {
    final String title = product.variant.isEmpty ? product.category.name : product.variant.name;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Ikonka tovar turini aytadi: IMEI talab qilingani — texnika.
              Container(
                width: ScreenSize.h38,
                height: ScreenSize.h38,
                decoration: BoxDecoration(
                  color: AppTheme.colors.blue.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(ScreenSize.r12),
                ),
                child: Icon(
                  product.imeis.isNotEmpty ? Icons.smartphone_outlined : Icons.inventory_2_outlined,
                  size: ScreenSize.h18,
                  color: AppTheme.colors.blue,
                ),
              ),

              Gap(ScreenSize.w10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title.isEmpty ? "Nomsiz tovar" : title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                    ),

                    if (_kind.isNotEmpty) ...<Widget>[
                      Gap(ScreenSize.h2),
                      Text(
                        _kind,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.bodySmall,
                      ),
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
              else ...<Widget>[
                _action(icon: Icons.edit_outlined, color: AppTheme.colors.primary, onTap: editPress),
                Gap(ScreenSize.w4),
                _action(icon: Icons.delete_outline, color: AppTheme.colors.red, onTap: removePress),
              ],
            ],
          ),

          Gap(ScreenSize.h10),
          Divider(height: ScreenSize.h1, thickness: ScreenSize.h1, color: AppSurface.line()),

          if (product.supplier.name.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h8),
            Row(
              children: <Widget>[
                Text("Ta'minotchi", style: AppTheme.data.textTheme.bodySmall),

                Gap(ScreenSize.w10),
                Expanded(
                  child: Text(
                    product.supplier.name,
                    maxLines: 2,
                    textAlign: TextAlign.end,
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
                  ),
                ),
              ],
            ),
          ],

          Gap(ScreenSize.h10),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "${Money.format(product.price)} × ${product.count}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(ScreenSize.r10),
                ),
                child: Text(
                  Money.withUnit(product.total),
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          if (product.imeis.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h8),
            ImeiList(values: product.imeis, chipColor: AppTheme.colors.backcolor),
          ],
        ],
      ),
    );
  }

  Widget _action({required IconData icon, required Color color, required VoidCallback onTap}) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ScreenSize.r12),
    child: Container(
      width: ScreenSize.h34,
      height: ScreenSize.h34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
      ),
      child: Icon(icon, size: ScreenSize.h18, color: color),
    ),
  );

}
