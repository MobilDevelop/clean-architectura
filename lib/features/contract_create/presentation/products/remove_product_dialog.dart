import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';

/// Tovarni o'chirishni tasdiqlash. O'chirish serverda darhol bajariladi va
/// qaytarib bo'lmaydi — shuning uchun so'raladi.
Future<bool> showRemoveProductDialog({required BuildContext context, required ContractProduct product}) async {
  final String title = product.variant.isEmpty ? product.category.name : product.variant.name;

  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => AppDialog(
      icon: AppIcons.delete,
      accent: AppTheme.colors.red,
      title: "Tovarni o'chirish",
      message: title.isEmpty ? "Tanlangan tovar shartnomadan olib tashlanadi." : "«$title» shartnomadan olib tashlanadi.",
      actionLabel: "O'chirish",
      cancelLabel: "Bekor qilish",
      onAction: () => Navigator.of(context).pop(true),
    ),
  );

  return result ?? false;
}
