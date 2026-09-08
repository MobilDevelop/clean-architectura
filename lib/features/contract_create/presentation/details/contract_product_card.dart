import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnomadagi bitta tovar.
final class ContractProductCard extends StatelessWidget {
  const ContractProductCard({super.key, required this.product});

  final ContractProduct product;

  @override
  Widget build(BuildContext context) {
    final String title = product.variant.isEmpty ? product.category.name : product.variant.name;

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h10),
      padding: EdgeInsets.all(ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.backcolor,
        borderRadius: BorderRadius.circular(ScreenSize.r16),
        border: AppSurface.border(alpha: .5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.isEmpty ? "Nomsiz tovar" : title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
          ),

          if (product.brand.name.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h2),
            Text(product.brand.name, style: AppTheme.data.textTheme.bodySmall),
          ],

          Gap(ScreenSize.h8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  "${Money.format(product.price)} × ${product.count}",
                  style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
                ),
              ),

              Text(
                Money.withUnit(product.total),
                style: AppTheme.data.textTheme.titleSmall?.copyWith(
                  color: AppTheme.colors.blackSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          if (product.supplier.name.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h6),
            Text("Yetkazib beruvchi: ${product.supplier.name}", style: AppTheme.data.textTheme.bodySmall),
          ],

          if (product.imeis.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h8),
            Wrap(
              spacing: ScreenSize.w6,
              runSpacing: ScreenSize.h4,
              children: product.imeis.map(_imei).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _imei(String value) => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h8, vertical: ScreenSize.h2),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r8),
      border: AppSurface.border(alpha: .5),
    ),
    child: Text(value, style: AppTheme.data.textTheme.bodySmall),
  );
}
