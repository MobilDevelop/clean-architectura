import 'dart:io';

import 'package:colloborator_v3/core/network/dio_client.dart';
import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/underwriter/data/models/underwriter_body.dart';
import 'package:colloborator_v3/features/underwriter/data/models/underwriter_dto.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:dio/dio.dart';

/// Javob tipi hamma joyda ataylab `dynamic`.
///
/// `get<Map<String, dynamic>>` javob obyekt bo'lmaganda Dio ichida yiqiladi
/// (`dio_mixin.dart:807`, `response.data as T?`). Yiqilish esa interceptor
/// zanjiri **tugagandan keyin** sodir bo'ladi (`dio_mixin.dart:576`) — ya'ni
/// `ErrorReportInterceptor` uni ko'rmaydi ham: ekran «Xatolik yuz berdi»
/// deydi, botga esa hech nima ketmaydi. Shakl qarori shu sababli Dio'da emas,
/// DTO va `JsonParser` da (4.4).
final class UnderwriterRemoteDatasource {
  const UnderwriterRemoteDatasource({required this._dio, required this._upload});

  final Dio _dio;

  /// Imzolangan havolaga yozish uchun — interceptorsiz klient.
  final UploadClient _upload;

  /// Javob `data` ichida emas, yuqori darajada keladi.
  Future<UnderwriterDataDto?> load(int contractId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.underwriters,
      queryParameters: <String, dynamic>{'contract_id': contractId},
    );

    return UnderwriterDataDto.tryFrom(result.data);
  }

  Future<List<MilitaryPositionDto>> getPositions() async {
    final Response<dynamic> result = await _dio.get<dynamic>(Endpoints.militaryPositions);

    return JsonParser.list(_data(result.data), fromJson: MilitaryPositionDto.fromJson);
  }

  Future<List<OptionDto>> getCarBrands() async {
    final Response<dynamic> result = await _dio.get<dynamic>(Endpoints.carBrands);

    return JsonParser.list(_data(result.data), fromJson: OptionDto.fromJson);
  }

  Future<List<OptionDto>> getCarModels(int brandId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.carModels,
      queryParameters: <String, dynamic>{'brand_id': brandId},
    );

    return JsonParser.list(_data(result.data), fromJson: OptionDto.fromJson);
  }

  /// Imzolangan havola so'raydi. `content_type` — MIME emas, **kengaytma**.
  Future<FileDirectionDto?> requestUpload({required String extension, required int length}) async {
    final Response<dynamic> result = await _dio.post<dynamic>(
      Endpoints.uploadS3Url,
      data: <String, dynamic>{'content_type': extension, 'content_length': length},
    );

    return JsonParser.object(result.data, fromJson: FileDirectionDto.fromJson);
  }

  /// Baytlarni imzolangan havolaga yozadi.
  Future<void> putToStorage({
    required String url,
    required List<int> bytes,
    required String mime,
  }) => _upload.dio.put<void>(
    url,
    data: Stream<List<int>>.fromIterable(<List<int>>[bytes]),
    options: Options(
      headers: <String, dynamic>{
        Headers.contentTypeHeader: mime,
        Headers.contentLengthHeader: bytes.length,
        'x-amz-acl': 'public-read',
      },
      responseType: ResponseType.plain,
    ),
  );

  Future<List<int>> readBytes(File file) => file.readAsBytes();

  Future<void> save(SaveUnderwriterParams params) {
    final Map<String, dynamic> body = underwriterBody(params);
    final int editId = params.form.editId;

    return editId == 0
        ? _dio.post<dynamic>(Endpoints.underwriters, data: body)
        : _dio.put<dynamic>('${Endpoints.underwriters}/$editId', data: body);
  }

  /// Ma'lumotnomalar `data` ichida keladi. O'ram bo'lmasa javobning o'zi
  /// beriladi — shaklni `JsonParser` hal qiladi va mos kelmasa botga aytadi.
  Object? _data(Object? body) => body is Map ? body['data'] : body;
}
