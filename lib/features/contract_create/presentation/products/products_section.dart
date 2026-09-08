import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/editable_product_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Tovarlar ro'yxati, umumiy summa va "qo'shish" tugmasi.
final class ProductsSection extends StatelessWidget {
  const ProductsSection({
    super.key,
    required this.products,
    required this.busyProductId,
    required this.isAdding,
    required this.errorText,
    required this.addPress,
    required this.editPress,
    required this.removePress,
  });

  final List<ContractProduct> products;
  final int? busyProductId;
  final bool isAdding;

  /// Tovar yo'qligini bildiruvchi matn. Widget uni hisoblamaydi (6.7).
  final String? errorText;

  final VoidCallback addPress;
  final ValueChanged<ContractProduct> editPress;
  final ValueChanged<ContractProduct> removePress;

  int get _total => products.fold(0, (int sum, ContractProduct e) => sum + e.total);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Tovarlar",
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
              ),
            ),

            if (products.isNotEmpty)
              Text(
                Money.withUnit(_total),
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
              ),
          ],
        ),

        Gap(ScreenSize.h10),
        for (final ContractProduct item in products)
          EditableProductCard(
            product: item,
            isBusy: item.id == busyProductId,
            editPress: () => editPress(item),
            removePress: () => removePress(item),
          ),

        _addButton(),

        if (errorText != null) ...<Widget>[
          Gap(ScreenSize.h8),
          Text(errorText ?? '', style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.red)),
        ],
      ],
    );
  }

  Widget _addButton() => InkWell(
    onTap: isAdding ? null : addPress,
    borderRadius: BorderRadius.circular(ScreenSize.r18),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .3)),
      ),
      child: isAdding
          ? Center(
              child: SizedBox(
                width: ScreenSize.h20,
                height: ScreenSize.h20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.add, size: ScreenSize.h20, color: AppTheme.colors.primary),
                Gap(ScreenSize.w6),
                Text(
                  "Tovar qo'shish",
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
                ),
              ],
            ),
    ),
  );
}
