import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';

abstract interface class ContractCreateRepository {
  Future<Result<ContractDetails>> getDetails(int contractId);

  Future<Result<Paged<CatalogItem>>> getSuppliers(CatalogQuery query);
  Future<Result<Paged<ProductCategory>>> getCategories(CategoryQuery query);
  Future<Result<Paged<CatalogItem>>> getBrands(BrandQuery query);
  Future<Result<Paged<CatalogItem>>> getVariants(VariantQuery query);

  /// Qoralama yaratadi va uning id sini qaytaradi.
  Future<Result<int>> createDraft(int clientId);

  /// Tovar qo'shadi va qatorning id sini qaytaradi.
  Future<Result<int>> addProduct(AddProductParams params);

  Future<Result<void>> updateProduct(UpdateProductParams params);
  Future<Result<void>> deleteProduct(int productId);

  Future<Result<List<int>>> getPaymentDays(int contractId);
  Future<Result<void>> submit(SubmitContractParams params);
}
