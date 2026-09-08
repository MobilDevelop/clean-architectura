import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:equatable/equatable.dart';

/// Tovar toifasi. `requiresImei` — bu toifadagi tovarning har bir nusxasi
/// alohida raqamlanadi (telefon, planshet).
final class ProductCategory extends Equatable {
  const ProductCategory({required this.id, required this.name, required this.requiresImei});

  final int id;
  final String name;

  /// Backend uni `imei` bayrog'ida yuboradi.
  final bool requiresImei;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name, requiresImei];
}

enum ProductDraftIssue {
  none,
  supplierMissing,
  categoryMissing,
  variantMissing,
  priceMissing,
  countMissing,
  imeiMissing,
  imeiCountMismatch,
}

/// Tovar qo'shish formasi.
///
/// Miqdor va IMEI bir-birini almashtiradi: raqamlanadigan toifada miqdor
/// kiritilmaydi, u skanerlangan IMEI'lar soniga teng bo'ladi.
final class ProductDraft extends Equatable {
  const ProductDraft({
    this.supplier,
    this.category,
    this.brand,
    this.variant,
    this.price = 0,
    this.count = 1,
    this.imeis = const <String>[],
  });

  final CatalogItem? supplier;
  final ProductCategory? category;

  /// Brend ixtiyoriy: ayrim toifalarda umuman bo'lmaydi.
  final CatalogItem? brand;

  final CatalogItem? variant;

  /// Butun so'mda.
  final int price;

  final int count;
  final List<String> imeis;

  /// Raqamlanadigan toifada miqdor IMEI'lar sonidan olinadi.
  bool get requiresImei => category?.requiresImei ?? false;

  int get effectiveCount => requiresImei ? imeis.length : count;

  int get total => price * effectiveCount;

  ProductDraftIssue get issue {
    if (supplier == null) return ProductDraftIssue.supplierMissing;
    if (category == null) return ProductDraftIssue.categoryMissing;
    if (variant == null) return ProductDraftIssue.variantMissing;
    if (price <= 0) return ProductDraftIssue.priceMissing;

    if (requiresImei) {
      if (imeis.isEmpty) return ProductDraftIssue.imeiMissing;

      return ProductDraftIssue.none;
    }

    if (count <= 0) return ProductDraftIssue.countMissing;

    return ProductDraftIssue.none;
  }

  /// Yuqoridagi tanlov o'zgarsa, unga bog'liqlari bekor bo'ladi.
  ProductDraft withSupplier(CatalogItem value) =>
      ProductDraft(supplier: value, price: price);

  ProductDraft withCategory(ProductCategory value) =>
      ProductDraft(supplier: supplier, category: value, price: price);

  ProductDraft withBrand(CatalogItem value) =>
      ProductDraft(supplier: supplier, category: category, brand: value, price: price);

  ProductDraft copyWith({
    CatalogItem? variant,
    int? price,
    int? count,
    List<String>? imeis,
  }) => ProductDraft(
    supplier: supplier,
    category: category,
    brand: brand,
    variant: variant ?? this.variant,
    price: price ?? this.price,
    count: count ?? this.count,
    imeis: imeis ?? this.imeis,
  );

  /// Server qator id sini bergach shartnoma qatoriga aylanadi. Tanlanmagan
  /// maydon `CatalogItem` ning bo'sh nusxasiga tushadi — bu holat validatsiya
  /// o'tganidan keyin yuz bermaydi, lekin tip uni talab qiladi.
  ContractProduct toProduct(int id) => ContractProduct(
    id: id,
    supplier: supplier ?? const CatalogItem(id: 0, name: ''),
    category: CatalogItem(id: category?.id ?? 0, name: category?.name ?? ''),
    brand: brand ?? const CatalogItem(id: 0, name: ''),
    variant: variant ?? const CatalogItem(id: 0, name: ''),
    price: price,
    count: effectiveCount,
    imeis: imeis,
  );

  @override
  List<Object?> get props => [supplier, category, brand, variant, price, count, imeis];
}
