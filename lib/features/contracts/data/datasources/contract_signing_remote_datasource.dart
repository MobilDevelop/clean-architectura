import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/signature_result_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:dio/dio.dart';

final class ContractSigningRemoteDatasource {
  const ContractSigningRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Shartnoma matni HTML bo'lib keladi, `data` o'ramisiz.
  ///
  /// `ResponseType.plain` — javob JSON emas: uni parse qilishga urinish
  /// bekorga vaqt yeydi va katta hujjatda yiqiladi.
  Future<String> getContractFile(ContractFileParams params) async {
    final Response<String> result = await _dio.post<String>(
      params.isFlex ? Endpoints.electronicFlexContract : Endpoints.electronicContract,
      data: <String, dynamic>{'contract_id': params.contractId},
      options: Options(responseType: ResponseType.plain),
    );

    return result.data ?? '';
  }

  /// Yuz tekshiruvi. Mijoz va kafil uchun tanasi bir xil, endpoint boshqa —
  /// `type` yuborilmaydi, manzilning o'zi kimligini bildiradi.
  ///
  /// Baytlar ikki marta ketadi: `front` (base64) va `client_face` (multipart).
  /// Flex ham shunday qiladi; backend qaysinisini o'qishi so'ralgan.
  Future<void> confirmFace(FaceConfirmParams params) async {
    final SigningParticipant participant = params.participant;

    final FormData body = FormData.fromMap(<String, dynamic>{
      'contract_id': params.contractId,
      'front': 'data:image/jpg;base64,${await _encoded(params.photo.path)}',
      'client_face': await MultipartFile.fromFile(params.photo.path, filename: 'face.jpg'),
      'passport_series_number': participant.passport,
      'birth_date': participant.birthday,
      'client_id': participant.id,
      'accepted_oferta': true,
    });

    await _dio.post<dynamic>(
      participant.isClient ? Endpoints.confirmClientFace : Endpoints.confirmGuarantorFace,
      data: body,
    );
  }

  Future<SignatureResultDto?> sign(SignatureParams params) async {
    final SigningParticipant participant = params.participant;

    final FormData body = FormData.fromMap(<String, dynamic>{
      'contract_id': params.contractId,
      'client_id': participant.id,
      'sign': MultipartFile.fromBytes(params.signature, filename: 'sign.png'),
      'comment': params.comment,
    });

    final Response<dynamic> result = await _dio.post<dynamic>(
      participant.isClient ? Endpoints.signClientContract : Endpoints.signGuarantorContract,
      data: body,
    );

    final Map<String, dynamic>? json = JsonParser.object<Map<String, dynamic>>(
      result.data,
      fromJson: (Map<String, dynamic> value) => value,
    );

    if (json == null) return null;

    return SignatureResultDto.fromJson(json, statusCode: result.statusCode ?? 0);
  }

  /// Rasmni base64 ga o'girish alohida izolyatda — asosiy oqim kadr
  /// tashlamasligi uchun (`customer_remote_datasource.dart` bilan bir xil).
  Future<String> _encoded(String path) =>
      Isolate.run(() => base64Encode(File(path).readAsBytesSync()));
}
