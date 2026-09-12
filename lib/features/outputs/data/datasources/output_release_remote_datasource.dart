import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:dio/dio.dart';

final class OutputReleaseRemoteDatasource {
  const OutputReleaseRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Chiqim tasdig'i: surat `multipart` bo'lib ketadi, shuning uchun tanasi
  /// JSON emas, `FormData`.
  Future<void> confirmRelease(ReleaseParams params) async {
    final FormData body = FormData.fromMap(<String, dynamic>{
      'code': params.code.trim(),
      'client_id': params.clientId,
      'contract_id': params.contractId,
      'products_picture': await MultipartFile.fromFile(
        params.photo.path,
        filename: 'products.jpg',
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });

    await _dio.post<dynamic>(Endpoints.outputSmsConfirm, data: body);
  }

  Future<void> returnProducts(ProductReturnParams params) async {
    await _dio.put<dynamic>(
      Endpoints.productReturned,
      data: <String, dynamic>{
        'contract_id': params.contractId,
        'product_ids': params.productIds,
      },
    );
  }
}
