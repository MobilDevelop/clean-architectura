import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';

/// Ma'lumotnoma javobining umumiy qobig'i.
///
/// Backend Laravel uslubida `data` + `meta` yuboradi. `meta` kelmasa, bo'sh
/// sahifa oxiri deb hisoblanadi — aks holda ro'yxat oxirida so'rov cheksiz
/// takrorlanardi.
Paged<T> pagedFrom<T>(Map<String, dynamic>? body, List<T> items) {
  final Object? meta = body?['meta'];

  if (meta is Map<String, dynamic>) {
    final int current = meta['current_page'] as int? ?? 0;
    final int last = meta['last_page'] as int? ?? 0;

    if (current > 0 && last > 0) return Paged<T>(items: items, isLast: current >= last);
  }

  return Paged<T>(items: items, isLast: items.isEmpty);
}

final class CatalogItemDto {
  const CatalogItemDto({required this.id, required this.name});

  factory CatalogItemDto.fromJson(Map<String, dynamic> json) =>
      CatalogItemDto(id: json['id'] as int? ?? 0, name: json['name'] as String? ?? '');

  /// Tovar nomi to'liq nom bilan keladi, bo'lmasa oddiy nom bilan.
  factory CatalogItemDto.variantFromJson(Map<String, dynamic> json) => CatalogItemDto(
    id: json['id'] as int? ?? 0,
    name: json['fullname'] as String? ?? json['name'] as String? ?? '',
  );

  final int id;
  final String name;

  CatalogItem toEntity() => CatalogItem(id: id, name: name);
}

final class ProductCategoryDto {
  const ProductCategoryDto({required this.id, required this.name, required this.imei});

  factory ProductCategoryDto.fromJson(Map<String, dynamic> json) => ProductCategoryDto(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    // Toifadagi tovar alohida raqamlanadimi.
    imei: json['imei'] as bool? ?? false,
  );

  final int id;
  final String name;
  final bool imei;

  ProductCategory toEntity() => ProductCategory(id: id, name: name, requiresImei: imei);
}

/// Ro'yxat javobidan elementlarni oladi.
List<T> catalogList<T>(Map<String, dynamic>? body, T Function(Map<String, dynamic>) fromJson) =>
    JsonParser.list(body?['data'], fromJson: fromJson);
