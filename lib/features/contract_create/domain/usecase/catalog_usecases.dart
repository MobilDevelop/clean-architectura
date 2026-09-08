import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';

final class GetSuppliersUsecase implements UseCase<Paged<CatalogItem>, CatalogQuery> {
  const GetSuppliersUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<Paged<CatalogItem>>> call(CatalogQuery params) => _repository.getSuppliers(params);
}

final class GetCategoriesUsecase implements UseCase<Paged<ProductCategory>, CategoryQuery> {
  const GetCategoriesUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<Paged<ProductCategory>>> call(CategoryQuery params) => _repository.getCategories(params);
}

final class GetBrandsUsecase implements UseCase<Paged<CatalogItem>, BrandQuery> {
  const GetBrandsUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<Paged<CatalogItem>>> call(BrandQuery params) => _repository.getBrands(params);
}

final class GetVariantsUsecase implements UseCase<Paged<CatalogItem>, VariantQuery> {
  const GetVariantsUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<Paged<CatalogItem>>> call(VariantQuery params) => _repository.getVariants(params);
}
