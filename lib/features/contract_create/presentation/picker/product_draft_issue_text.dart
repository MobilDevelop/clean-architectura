import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';

/// Har bir xato o'z maydoni tagida chiqadi (7.5).
abstract final class ProductDraftIssueText {
  static String? supplier(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.supplierMissing ? "Yetkazib beruvchini tanlang" : null;

  static String? category(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.categoryMissing ? "Toifani tanlang" : null;

  static String? variant(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.variantMissing ? "Tovarni tanlang" : null;

  static String? price(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.priceMissing ? "Narxni kiriting" : null;

  static String? count(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.countMissing ? "Miqdorni kiriting" : null;

  static String? imei(ProductDraftIssue issue) =>
      issue == ProductDraftIssue.imeiMissing ? "Qurilma yorlig'ini suratga oling" : null;
}
