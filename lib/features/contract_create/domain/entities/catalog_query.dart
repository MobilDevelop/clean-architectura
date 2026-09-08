import 'package:equatable/equatable.dart';

/// Ma'lumotnoma so'rovi: qidiruv matni va sahifa.
final class CatalogQuery extends Equatable {
  const CatalogQuery({required this.search, required this.page});

  final String search;

  /// 1 dan boshlanadi.
  final int page;

  @override
  List<Object?> get props => [search, page];
}

/// Toifalar bitta yetkazib beruvchiga tegishli.
final class CategoryQuery extends Equatable {
  const CategoryQuery({required this.query, required this.supplierId});

  final CatalogQuery query;
  final int supplierId;

  @override
  List<Object?> get props => [query, supplierId];
}

/// Brendlar bitta toifaga tegishli.
final class BrandQuery extends Equatable {
  const BrandQuery({required this.query, required this.categoryId});

  final CatalogQuery query;
  final int categoryId;

  @override
  List<Object?> get props => [query, categoryId];
}

/// Tovarlar toifaga, ixtiyoriy ravishda brendga ham tegishli.
final class VariantQuery extends Equatable {
  const VariantQuery({required this.query, required this.categoryId, required this.brandId});

  final CatalogQuery query;
  final int categoryId;

  /// `0` — brend tanlanmagan, filtr qo'llanmaydi.
  final int brandId;

  @override
  List<Object?> get props => [query, categoryId, brandId];
}
