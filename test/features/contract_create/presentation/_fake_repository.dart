import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';

/// Testlar uchun soxta shartnoma repositoryi. Har bir metod natijasi tashqaridan
/// beriladi — bloc'ning muvaffaqiyatsizlikdagi xatti-harakati shu bilan sinaladi.
final class FakeContractCreateRepository implements ContractCreateRepository {
  Result<int> draftResult = const Ok<int>(77);
  Result<int> addResult = const Ok<int>(1);
  Result<void> updateResult = const Ok<void>(null);
  Result<void> deleteResult = const Ok<void>(null);
  Result<List<int>> paymentDaysResult = const Ok<List<int>>(<int>[5, 15, 25]);
  Result<void> submitResult = const Ok<void>(null);
  Result<ContractDetails> detailsResult = const Err<ContractDetails>(UnknownFailure('yo`q'));
  Result<List<String>> scanResult = const Ok<List<String>>(<String>['358240051111110']);

  /// Javob kechikishini sinash uchun — ketma-ket hodisalarni tekshiradi.
  Duration scanDelay = Duration.zero;

  int draftCalls = 0;
  int addCalls = 0;
  int deleteCalls = 0;
  int submitCalls = 0;
  int scanCalls = 0;
  SubmitContractParams? lastSubmit;
  ScanImeiParams? lastScan;
  UpdateProductParams? lastUpdate;

  @override
  Future<Result<int>> createDraft(int clientId) async {
    draftCalls++;

    return draftResult;
  }

  @override
  Future<Result<List<String>>> scanImei(ScanImeiParams params) async {
    scanCalls++;
    lastScan = params;
    if (scanDelay > Duration.zero) await Future<void>.delayed(scanDelay);

    return scanResult;
  }

  @override
  Future<Result<int>> addProduct(AddProductParams params) async {
    addCalls++;

    return addResult;
  }

  @override
  Future<Result<void>> updateProduct(UpdateProductParams params) async {
    lastUpdate = params;

    return updateResult;
  }

  @override
  Future<Result<void>> deleteProduct(int productId) async {
    deleteCalls++;

    return deleteResult;
  }

  @override
  Future<Result<List<int>>> getPaymentDays(int contractId) async => paymentDaysResult;

  @override
  Future<Result<void>> submit(SubmitContractParams params) async {
    submitCalls++;
    lastSubmit = params;

    return submitResult;
  }

  @override
  Future<Result<ContractDetails>> getDetails(int contractId) async => detailsResult;

  @override
  Future<Result<Paged<CatalogItem>>> getSuppliers(CatalogQuery query) async =>
      const Ok<Paged<CatalogItem>>(Paged<CatalogItem>.last(<CatalogItem>[]));

  @override
  Future<Result<Paged<ProductCategory>>> getCategories(CategoryQuery query) async =>
      const Ok<Paged<ProductCategory>>(Paged<ProductCategory>.last(<ProductCategory>[]));

  @override
  Future<Result<Paged<CatalogItem>>> getBrands(BrandQuery query) async =>
      const Ok<Paged<CatalogItem>>(Paged<CatalogItem>.last(<CatalogItem>[]));

  @override
  Future<Result<Paged<CatalogItem>>> getVariants(VariantQuery query) async =>
      const Ok<Paged<CatalogItem>>(Paged<CatalogItem>.last(<CatalogItem>[]));
}
