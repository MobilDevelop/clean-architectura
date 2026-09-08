import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_create_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/catalog_dto.dart';
import 'package:colloborator_v3/features/contract_create/data/models/contract_details_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';
import 'package:dio/dio.dart';

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
  Future<Result<int>> createDraft(int clientId) async {
    try {
      final ({int? contractId, String message}) result = await _remote.createDraft(clientId);
      final int? id = result.contractId;

      if (id == null || id == 0) {
        return Err(ClientFailure(result.message.isEmpty ? "Qoralama yaratilmadi" : result.message));
      }

      return Ok(id);
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<int>> addProduct(AddProductParams params) async {
    try {
      final int? id = await _remote.addProduct(params);

      // Qator id si kelmasa, keyingi tahrirlash va o'chirish ishlamaydi —
      // jimgina o'tkazib yuborish mumkin emas.
      if (id == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      return Ok(id);
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<void>> updateProduct(UpdateProductParams params) => _run(() => _remote.updateProduct(params));

  @override
  Future<Result<void>> deleteProduct(int productId) => _run(() => _remote.deleteProduct(productId));

  @override
  Future<Result<void>> submit(SubmitContractParams params) => _run(() => _remote.submit(params));

  @override
  Future<Result<List<int>>> getPaymentDays(int contractId) async {
    try {
      return Ok(await _remote.getPaymentDays(contractId));
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  /// Javob tanasi kerak bo'lmagan amallar bir xil yo'ldan o'tadi.
  Future<Result<void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Ok(null);
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  /// Ma'lumotnoma so'rovlari bir xil yo'ldan o'tadi.
  Future<Result<Paged<T>>> _paged<T, D>(Future<Paged<D>> Function() load, T Function(D) toEntity) async {
    try {
      final Paged<D> page = await load();

      return Ok(Paged<T>(items: page.items.map(toEntity).toList(), isLast: page.isLast));
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<ContractDetails>> getDetails(int contractId) async {
    try {
      final ContractDetailsDto? dto = await _remote.getDetails(contractId);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}
