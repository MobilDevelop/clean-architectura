import 'dart:async';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/product_picker_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/product_draft_issue_text.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/catalog_sheet.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/imei_input.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Tovar tanlash. Natijani `ProductDraft` sifatida qaytaradi — yozuvni
/// shartnoma ekrani bajaradi.
final class ProductPickerPage extends StatefulWidget {
  const ProductPickerPage({super.key});

  @override
  State<ProductPickerPage> createState() => _ProductPickerPageState();
}

final class _ProductPickerPageState extends State<ProductPickerPage> {
  late final TextEditingController _price;
  late final TextEditingController _count;
  late final ProductPickerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _price = TextEditingController();
    _count = TextEditingController(text: '1');
    _bloc = context.read<ProductPickerBloc>();
  }

  @override
  void dispose() {
    _price.dispose();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return BlocListener<ProductPickerBloc, ProductPickerState>(
      listenWhen: (ProductPickerState previous, ProductPickerState current) => current.isReady && !previous.isReady,
      listener: (BuildContext context, ProductPickerState state) => context.pop(state.draft),
      child: Scaffold(
        backgroundColor: AppTheme.colors.backcolor,
        body: Stack(
          children: <Widget>[
            const BackgroundWash(),

            Positioned.fill(
              child: BlocBuilder<ProductPickerBloc, ProductPickerState>(
                builder: (BuildContext context, ProductPickerState state) => _form(state, topInset),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: PageHeader(title: "Tovar qo'shish", topInset: topInset, backPress: context.pop),
            ),
          ],
        ),

        bottomNavigationBar: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h12),
          child: BlocSelector<ProductPickerBloc, ProductPickerState, int>(
            selector: (ProductPickerState state) => state.draft.total,
            builder: (BuildContext context, int total) => MainButton(
              text: total > 0 ? "Qo'shish · ${Money.withUnit(total)}" : "Qo'shish",
              onPressed: () => _bloc.add(const SubmitRequested()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(ProductPickerState state, double topInset) {
    final ProductDraft draft = state.draft;
    final ProductDraftIssue issue = state.issue;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset + ScreenSize.h56 + ScreenSize.h16,
        left: ScreenSize.h16,
        right: ScreenSize.h16,
        bottom: ScreenSize.h40,
      ),
      child: Column(
        children: <Widget>[
          SelectTile(
            title: "Yetkazib beruvchi",
            hint: "Tanlang",
            value: draft.supplier?.name ?? '',
            errorText: ProductDraftIssueText.supplier(issue),
            onTap: () => unawaited(_pickSupplier()),
          ),

          Gap(ScreenSize.h14),
          SelectTile(
            title: "Toifa",
            hint: draft.supplier == null ? "Avval yetkazib beruvchini tanlang" : "Tanlang",
            value: draft.category?.name ?? '',
            errorText: ProductDraftIssueText.category(issue),
            enabled: draft.supplier != null,
            onTap: () => unawaited(_pickCategory()),
          ),

          Gap(ScreenSize.h14),
          SelectTile(
            title: "Brend",
            hint: draft.category == null ? "Avval toifani tanlang" : "Tanlang (ixtiyoriy)",
            value: draft.brand?.name ?? '',
            enabled: draft.category != null,
            onTap: () => unawaited(_pickBrand()),
          ),

          Gap(ScreenSize.h14),
          SelectTile(
            title: "Tovar",
            hint: draft.category == null ? "Avval toifani tanlang" : "Tanlang",
            value: draft.variant?.name ?? '',
            errorText: ProductDraftIssueText.variant(issue),
            enabled: draft.category != null,
            onTap: () => unawaited(_pickVariant()),
          ),

          Gap(ScreenSize.h14),
          TextInputWidget(
            controller: _price,
            title: "Narx",
            hint: "0",
            keyboardType: TextInputType.number,
            errorText: ProductDraftIssueText.price(issue),
            formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
            onChanged: (String value) => _bloc.add(PriceChanged(Money.parse(value))),
          ),

          Gap(ScreenSize.h14),
          // Raqamlanadigan toifada miqdor IMEI'lar sonidan olinadi.
          if (draft.requiresImei)
            ImeiInput(
              imeis: draft.imeis,
              errorText: ProductDraftIssueText.imei(issue),
              onAdded: (String value) => _bloc.add(ImeiAdded(value)),
              onRemoved: (String value) => _bloc.add(ImeiRemoved(value)),
            )
          else
            TextInputWidget(
              controller: _count,
              title: "Miqdor",
              hint: "1",
              keyboardType: TextInputType.number,
              errorText: ProductDraftIssueText.count(issue),
              formatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
              onChanged: (String value) => _bloc.add(CountChanged(int.tryParse(value) ?? 0)),
            ),
        ],
      ),
    );
  }

  Future<void> _pickSupplier() => showCatalogSheet<CatalogItem>(
    context: context,
    title: "Yetkazib beruvchi",
    hint: "Nomi bo'yicha qidirish",
    load: _bloc.loadSuppliers,
    labelOf: (CatalogItem item) => item.name,
    isSelected: (CatalogItem item) => item.id == _bloc.state.draft.supplier?.id,
    onPicked: (CatalogItem item) => _bloc.add(SupplierSelected(item)),
  );

  Future<void> _pickCategory() => showCatalogSheet<ProductCategory>(
      context: context,
      title: "Toifa",
      hint: "Nomi bo'yicha qidirish",
      load: _bloc.loadCategories,
      labelOf: (ProductCategory item) => item.name,
      subtitleOf: (ProductCategory item) => item.requiresImei ? "IMEI talab qiladi" : '',
      isSelected: (ProductCategory item) => item.id == _bloc.state.draft.category?.id,
      onPicked: (ProductCategory item) => _bloc.add(CategorySelected(item)),
    );

  Future<void> _pickBrand() => showCatalogSheet<CatalogItem>(
      context: context,
      title: "Brend",
      hint: "Nomi bo'yicha qidirish",
      load: _bloc.loadBrands,
      labelOf: (CatalogItem item) => item.name,
      isSelected: (CatalogItem item) => item.id == _bloc.state.draft.brand?.id,
      onPicked: (CatalogItem item) => _bloc.add(BrandSelected(item)),
    );

  Future<void> _pickVariant() => showCatalogSheet<CatalogItem>(
      context: context,
      title: "Tovar",
      hint: "Nomi bo'yicha qidirish",
      load: _bloc.loadVariants,
      labelOf: (CatalogItem item) => item.name,
      isSelected: (CatalogItem item) => item.id == _bloc.state.draft.variant?.id,
      onPicked: (CatalogItem item) => _bloc.add(VariantSelected(item)),
    );
}
