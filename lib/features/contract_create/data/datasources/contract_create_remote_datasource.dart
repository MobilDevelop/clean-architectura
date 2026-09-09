import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/data/models/add_product_dto.dart';
import 'package:colloborator_v3/features/contract_create/data/models/catalog_dto.dart';
import 'package:colloborator_v3/features/contract_create/data/models/contract_details_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:dio/dio.dart';

/// base64 asosiy oqimda hisoblanmaydi: bir megabaytlik rasm ekranni sezilarli
/// muddatga qotiradi.
Future<String> _encodedImage(String path) => Isolate.run(() => base64Encode(File(path).readAsBytesSync()));

final class ContractCreateRemoteDatasource {
  const ContractCreateRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<ContractDetailsDto?> getDetails(int contractId) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.loanById}$contractId',
    );

    // Javob ba'zi endpointlarda `data` ichida keladi.
    final Map<String, dynamic>? body = result.data;
    final Object? payload = body?['data'] ?? body;

    return JsonParser.object(payload, fromJson: ContractDetailsDto.fromJson);
  }

  Future<Paged<CatalogItemDto>> getSuppliers(CatalogQuery query) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.suppliers,
      queryParameters: <String, dynamic>{'search': query.search, 'page': query.page},
    );

    return pagedFrom(result.data, catalogList(result.data, CatalogItemDto.fromJson));
  }

  Future<Paged<ProductCategoryDto>> getCategories(CategoryQuery query) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.categories,
      queryParameters: <String, dynamic>{
        'search': query.query.search,
        'page': query.query.page,
        'partner_id': query.supplierId,
      },
    );

    return pagedFrom(result.data, catalogList(result.data, ProductCategoryDto.fromJson));
  }

  Future<Paged<CatalogItemDto>> getBrands(BrandQuery query) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.brands,
      queryParameters: <String, dynamic>{
        'search': query.query.search,
        'page': query.query.page,
        'category_id': query.categoryId,
      },
    );

    return pagedFrom(result.data, catalogList(result.data, CatalogItemDto.fromJson));
  }

  Future<Paged<CatalogItemDto>> getVariants(VariantQuery query) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.products,
      queryParameters: <String, dynamic>{
        'search': query.query.search,
        'page': query.query.page,
        'category_id': query.categoryId,
        if (query.brandId != 0) 'brand_id': query.brandId,
      },
    );

    return pagedFrom(result.data, catalogList(result.data, CatalogItemDto.variantFromJson));
  }

  /// Qoralama yaratadi va uning id sini qaytaradi.
  ///
  /// Server HTTP 200 bilan `contract_id: null` qaytarishi mumkin — bu xato,
  /// odatda mijozda ochiq shartnoma borligini bildiradi. Sabab javob matnida.
  Future<({int? contractId, String message})> createDraft(int clientId) async {
    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.loanDraft,
      data: <String, dynamic>{'client_id': clientId},
    );

    return (
      contractId: result.data?['contract_id'] as int?,
      message: result.data?['message'] as String? ?? '',
    );
  }

  /// Rasmdan IMEI o'qish. Javob `{"imeis": [...]}` shaklida keladi.
  Future<List<String>> scanImei(ScanImeiParams params) async {
    final String encoded = await _encodedImage(params.image.path);

    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.imeiImage,
      data: <String, dynamic>{
        'product_variant_id': params.variantId,
        // Prefiks flex bilan bir xil: rasm JPEG ga siqilib yuboriladi.
        'img': 'data:image/jpg;base64,$encoded',
      },
    );

    final Object? raw = result.data?['imeis'];
    if (raw is! List) return const <String>[];

    return raw.map((Object? e) => e?.toString() ?? '').where((String e) => e.isNotEmpty).toList();
  }

  /// Qo'shilgan qatorning id sini qaytaradi.
  Future<int?> addProduct(AddProductParams params) async {
    final Response<Map<String, dynamic>> result = await _dio.post<Map<String, dynamic>>(
      Endpoints.addLoanProduct,
      data: AddProductDto(params).toJson(),
    );

    final Object? data = result.data?['data'];

    return data is Map<String, dynamic> ? data['id'] as int? : result.data?['id'] as int?;
  }

  Future<void> updateProduct(UpdateProductParams params) => _dio.put<Map<String, dynamic>>(
    '${Endpoints.updateLoanProduct}${params.productId}',
    data: <String, dynamic>{
      'partner_id': params.supplierId,
      'price': params.price.toString(),
      'count': params.count.toString(),
    },
  );

  Future<void> deleteProduct(int productId) =>
      _dio.delete<Map<String, dynamic>>('${Endpoints.deleteLoanProduct}$productId');

  /// Serverdagi ruxsat etilgan to'lov kunlari.
  Future<List<int>> getPaymentDays(int contractId) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.paymentDays}$contractId',
    );

    final Object? days = result.data?['payment_days'];
    if (days is! List) return const <int>[];

    return days.whereType<int>().toList();
  }

  /// Skoringga yuborish. Yangi shartnomada `POST`, tahrirlashda `PUT`.
  Future<void> submit(SubmitContractParams params) {
    final Map<String, dynamic> body = <String, dynamic>{
      'contract_id': params.contractId,
      'term': params.termMonths,
      'payment_day': params.paymentDay,
      'formal': params.isFormal,
      'check_car_income': params.hasCarIncome,
      // Server so'ramagan bo'lsa kalit umuman yuborilmaydi.
      if (params.occupationTypeId != 0) 'occupation_type_id': params.occupationTypeId,
    };

    return params.isEdit
        ? _dio.put<Map<String, dynamic>>('${Endpoints.loans}/${params.contractId}', data: body)
        : _dio.post<Map<String, dynamic>>(Endpoints.loans, data: body);
  }
}
