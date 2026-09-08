import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:flutter_test/flutter_test.dart';

const CatalogItem _supplier = CatalogItem(id: 1, name: 'Texnomart');
const CatalogItem _brand = CatalogItem(id: 2, name: 'Samsung');
const CatalogItem _variant = CatalogItem(id: 3, name: 'A54');
const ProductCategory _plain = ProductCategory(id: 4, name: 'Muzlatgich', requiresImei: false);
const ProductCategory _imei = ProductCategory(id: 5, name: 'Telefon', requiresImei: true);

const ProductDraft _full = ProductDraft(
  supplier: _supplier,
  category: _plain,
  brand: _brand,
  variant: _variant,
  price: 500,
  count: 2,
);

void main() {
  group('validatsiya tartibi', () {
    test('yetkazib beruvchi birinchi', () {
      expect(const ProductDraft().issue, ProductDraftIssue.supplierMissing);
    });

    test('toifa ikkinchi', () {
      expect(const ProductDraft(supplier: _supplier).issue, ProductDraftIssue.categoryMissing);
    });

    test('tovar uchinchi', () {
      expect(const ProductDraft(supplier: _supplier, category: _plain).issue, ProductDraftIssue.variantMissing);
    });

    test('narx to‘rtinchi', () {
      expect(
        const ProductDraft(supplier: _supplier, category: _plain, variant: _variant).issue,
        ProductDraftIssue.priceMissing,
      );
    });

    test('oddiy toifada miqdor tekshiriladi', () {
      expect(_full.copyWith(count: 0).issue, ProductDraftIssue.countMissing);
    });

    test('to‘liq forma o‘tadi', () {
      expect(_full.issue, ProductDraftIssue.none);
      expect(_full.total, 1000);
    });
  });

  group('raqamlanadigan toifa', () {
    const ProductDraft base = ProductDraft(
      supplier: _supplier,
      category: _imei,
      variant: _variant,
      price: 1000,
    );

    test('IMEI kerak', () => expect(base.issue, ProductDraftIssue.imeiMissing));

    test('IMEI bo‘lsa o‘tadi', () {
      expect(base.copyWith(imeis: const <String>['1', '2']).issue, ProductDraftIssue.none);
    });

    test('miqdor IMEI sonidan olinadi', () {
      final ProductDraft draft = base.copyWith(imeis: const <String>['1', '2', '3'], count: 99);

      expect(draft.effectiveCount, 3);
      expect(draft.total, 3000);
    });

    test('miqdor kiritilmagani xato emas', () {
      expect(base.copyWith(imeis: const <String>['1'], count: 0).issue, ProductDraftIssue.none);
    });
  });

  group('kaskad bekor qilinishi', () {
    test('yetkazib beruvchi o‘zgarsa hammasi bekor, narx qoladi', () {
      final ProductDraft changed = _full.withSupplier(const CatalogItem(id: 9, name: 'Idea'));

      expect(changed.category, isNull);
      expect(changed.brand, isNull);
      expect(changed.variant, isNull);
      expect(changed.price, 500);
    });

    test('toifa o‘zgarsa brend va tovar bekor', () {
      final ProductDraft changed = _full.withCategory(_imei);

      expect(changed.supplier, _supplier);
      expect(changed.brand, isNull);
      expect(changed.variant, isNull);
    });

    test('brend o‘zgarsa faqat tovar bekor', () {
      final ProductDraft changed = _full.withBrand(const CatalogItem(id: 8, name: 'LG'));

      expect(changed.category, _plain);
      expect(changed.variant, isNull);
    });
  });
}
