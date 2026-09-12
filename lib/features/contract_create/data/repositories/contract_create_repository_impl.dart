import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_create_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/catalog_dto.dart';
import 'package:colloborator_v3/features/contract_create/data/models/contract_details_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';

final class ContractCreateRepositoryImpl implements ContractCreateRepository {
  const ContractCreateRepositoryImpl({required this._remote});

  final ContractCreateRemoteDatasource _remote;

  @override
  Future<Result<Paged<CatalogItem>>> getSuppliers(CatalogQuery query) =>
      _paged(() => _remote.getSuppliers(query), (CatalogItemDto dto) => dto.toEntity());

  @override
  Future<Result<Paged<ProductCategory>>> getCategories(CategoryQuery query) =>
      _paged(() => _remote.getCategories(query), (ProductCategoryDto dto) => dto.toEntity());

  @override
  Future<Result<Paged<CatalogItem>>> getBrands(BrandQuery query) =>
      _paged(() => _remote.getBrands(query), (CatalogItemDto dto) => dto.toEntity());

  @override
  Future<Result<Paged<CatalogItem>>> getVariants(VariantQuery query) =>
      _paged(() => _remote.getVariants(query), (CatalogItemDto dto) => dto.toEntity());

  /// Server HTTP 200 bilan ham muvaffaqiyatsizlikni aytishi mumkin:
  /// `contract_id: null` — odatda mijozda ochiq shartnoma bor. `ErrorMapper`
  /// bunday javobni ko'rmaydi, shuning uchun u shu yerda xatoga aylantiriladi.
  @override
  Future<Result<int>> createDraft(int clientId) => guard(() async {
      final ({int? contractId, String message}) result = await _remote.createDraft(clientId);
      final int? id = result.contractId;

      if (id == null || id == 0) {
        throw GuardFailure(ClientFailure(result.message.isEmpty ? "Qoralama yaratilmadi" : result.message));
      }

      return id;
  });

  /// Bo'sh ro'yxat xatoga aylantiriladi: server HTTP 200 qaytaradi, lekin
  /// foydalanuvchi uchun bu "topilmadi" degani va u ko'rinishi kerak (5.8).
  @override
  Future<Result<List<String>>> scanImei(ScanImeiParams params) async {
    final Result<List<String>> result = await guard(() => _remote.scanImei(params));

    return switch (result) {
      Ok(:final List<String> value) when value.isEmpty => const Err<List<String>>(
        ClientFailure("Rasmdan IMEI topilmadi. Yorliqni aniqroq suratga oling"),
      ),
      _ => result,
    };
  }

  @override
  Future<Result<int>> addProduct(AddProductParams params) => guard(() async {
      final int? id = await _remote.addProduct(params);

      // Qator id si kelmasa, keyingi tahrirlash va o'chirish ishlamaydi —
      // jimgina o'tkazib yuborish mumkin emas.
      if (id == null) throw const FormatException('javob obyekt emas');

      return id;
  });

  @override
  Future<Result<void>> updateProduct(UpdateProductParams params) => _run(() => _remote.updateProduct(params));

  @override
  Future<Result<void>> deleteProduct(int productId) => _run(() => _remote.deleteProduct(productId));

  @override
  Future<Result<void>> submit(SubmitContractParams params) => _run(() => _remote.submit(params));

  @override
  Future<Result<List<int>>> getPaymentDays(int contractId) => guard(() async {
      return await _remote.getPaymentDays(contractId);
  });

  /// Javob tanasi kerak bo'lmagan amallar bir xil yo'ldan o'tadi.
  Future<Result<void>> _run(Future<void> Function() action) => guard(() async {
      await action();
      return;
  });

  /// Ma'lumotnoma so'rovlari bir xil yo'ldan o'tadi.
  Future<Result<Paged<T>>> _paged<T, D>(Future<Paged<D>> Function() load, T Function(D) toEntity) => guard(() async {
      final Paged<D> page = await load();

      return Paged<T>(items: page.items.map(toEntity).toList(), isLast: page.isLast);
  });

  @override
  Future<Result<ContractDetails>> getDetails(int contractId) => guard(() async {
      final ContractDetailsDto? dto = await _remote.getDetails(contractId);

      if (dto == null) throw const FormatException('javob obyekt emas');

      return dto.toEntity();
  });
}
