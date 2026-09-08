import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';

/// Tovar qo'shish so'rovining tanasi.
///
/// Narx va miqdor satr sifatida yuboriladi — flex shunday qiladi va backend
/// shu yo'lda sinalgan. Son sifatida qabul qilinishi backenddan so'ralgan.
final class AddProductDto {
  const AddProductDto(this._params);

  final AddProductParams _params;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'contract_id': _params.contractId,
    'partner_id': _params.supplierId,
    'category_id': _params.categoryId,
    if (_params.brandId != 0) 'brand_id': _params.brandId,
    'product_variant_id': _params.variantId,
    'price': _params.price.toString(),
    'count': _params.count.toString(),
    if (_params.imeis.isNotEmpty) 'devices': _params.imeis,
  };
}
