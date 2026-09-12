import 'dart:async';

import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/contract_products/contract_products_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/product_edit_sheet.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/products_section.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/remove_product_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// «Tovarlar» tabi.
final class ProductsTab extends StatelessWidget {
  const ProductsTab({super.key, required this.productPicker});

  /// Tovar tanlash ekranini ochadi. Marshrutni router biladi (8.2).
  final Future<ProductDraft?> Function(BuildContext context) productPicker;

  Future<void> _add(BuildContext context) async {
    final ContractProductsBloc bloc = context.read<ContractProductsBloc>();

    // Qoralama hali yo'q bo'lsa ham katalog ochiladi: u shartnomaga bog'liq
    // emas, qoralama esa birinchi tovar qo'shilganda yaratiladi.
    final ProductDraft? draft = await productPicker(context);
    if (draft == null) return;

    bloc.add(ProductAdded(draft));
  }

  Future<void> _edit(BuildContext context, ContractProduct product) => showAppSheet(
    context: context,
    child: ProductEditSheet(
      product: product,
      saved: (int price, int count) => context.read<ContractProductsBloc>().add(
        ProductSaved(productId: product.id, price: price, count: count),
      ),
    ),
  );

  Future<void> _remove(BuildContext context, ContractProduct product) async {
    final ContractProductsBloc bloc = context.read<ContractProductsBloc>();
    final bool isConfirmed = await showRemoveProductDialog(context: context, product: product);

    if (!isConfirmed) return;

    bloc.add(ProductRemoved(product.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContractProductsBloc, ContractProductsState>(
      builder: (BuildContext context, ContractProductsState state) => ListView(
        padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h14, ScreenSize.h16, ScreenSize.h24),
        children: <Widget>[
          ProductsSection(
            products: state.products,
            busyProductId: state.busyProductId,
            isAdding: state.write == ProductWrite.adding,
            errorText: null,
            addPress: () => unawaited(_add(context)),
            editPress: (ContractProduct item) => unawaited(_edit(context, item)),
            removePress: (ContractProduct item) => unawaited(_remove(context, item)),
          ),
        ],
      ),
    );
  }
}
