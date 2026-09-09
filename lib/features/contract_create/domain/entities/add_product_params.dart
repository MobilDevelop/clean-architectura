import 'dart:io';

import 'package:equatable/equatable.dart';

/// Shartnomaga tovar qo'shish so'rovi.
///
/// Tekshiruv `ProductDraft` da bo'lib bo'lgan — bu yerga faqat to'liq
/// ma'lumot yetib keladi.
final class AddProductParams extends Equatable {
  const AddProductParams({
    required this.contractId,
    required this.supplierId,
    required this.categoryId,
    required this.brandId,
    required this.variantId,
    required this.price,
    required this.count,
    required this.imeis,
  });

  final int contractId;
  final int supplierId;
  final int categoryId;

  /// `0` — brend tanlanmagan, so'rovga qo'shilmaydi.
  final int brandId;

  final int variantId;

  /// Butun so'mda.
  final int price;

  final int count;
  final List<String> imeis;

  @override
  List<Object?> get props => [contractId, supplierId, categoryId, brandId, variantId, price, count, imeis];
}

/// IMEI'ni qurilma yorlig'ining rasmidan o'qish.
final class ScanImeiParams extends Equatable {
  const ScanImeiParams({required this.variantId, required this.image});

  /// Qaysi tovar ekani serverga aytiladi — u shunga qarab qidiradi.
  final int variantId;

  final File image;

  @override
  List<Object?> get props => [variantId, image.path];
}
