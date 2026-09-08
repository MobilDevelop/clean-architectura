import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Tovarning narxi va miqdorini o'zgartirish.
///
/// Faqat shu ikkisi: server `update_loan_product` da yetkazib beruvchi, narx va
/// miqdorni oladi, toifa va tovarni emas. Ularni o'zgartirish — qatorni
/// o'chirib qaytadan qo'shish.
final class ProductEditSheet extends StatefulWidget {
  const ProductEditSheet({super.key, required this.product, required this.saved});

  final ContractProduct product;

  /// `(narx, miqdor)`. Oyna o'zini yopadi — sahifa navigatorga tegmaydi.
  final void Function(int price, int count) saved;

  @override
  State<ProductEditSheet> createState() => _ProductEditSheetState();
}

final class _ProductEditSheetState extends State<ProductEditSheet> {
  late final TextEditingController _price;
  late final TextEditingController _count;

  /// IMEI li tovarda miqdor IMEI soniga teng — uni qo'lda o'zgartirib bo'lmaydi.
  bool get _isCountLocked => widget.product.imeis.isNotEmpty;

  String? _priceError;
  String? _countError;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController(text: Money.format(widget.product.price));
    _count = TextEditingController(text: "${widget.product.count}");
  }

  @override
  void dispose() {
    _price.dispose();
    _count.dispose();
    super.dispose();
  }

  void _save() {
    final int price = Money.parse(_price.text);
    final int count = _isCountLocked ? widget.product.imeis.length : Money.parse(_count.text);

    setState(() {
      _priceError = price <= 0 ? "Narxni kiriting" : null;
      _countError = count <= 0 ? "Miqdorni kiriting" : null;
    });

    if (price <= 0 || count <= 0) return;

    widget.saved(price, count);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.product.variant.isEmpty
        ? widget.product.category.name
        : widget.product.variant.name;

    return Padding(
      padding: EdgeInsets.only(
        left: ScreenSize.h16,
        right: ScreenSize.h16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + ScreenSize.h16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.isEmpty ? "Tovarni tahrirlash" : title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
          ),

          Gap(ScreenSize.h16),
          TextInputWidget(
            title: "Narxi",
            hint: "0",
            controller: _price,
            keyboardType: TextInputType.number,
            errorText: _priceError,
            formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
          ),

          Gap(ScreenSize.h12),
          TextInputWidget(
            title: "Miqdori",
            hint: "1",
            controller: _count,
            enabled: !_isCountLocked,
            keyboardType: TextInputType.number,
            errorText: _countError,
            formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
          ),

          if (_isCountLocked) ...<Widget>[
            Gap(ScreenSize.h6),
            Text(
              "Miqdor IMEI soniga teng",
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
            ),
          ],

          Gap(ScreenSize.h20),
          MainButton(text: "Saqlash", onPressed: _save),
        ],
      ),
    );
  }
}
