import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/data/models/customer_info_dto.dart';
import 'package:colloborator_v3/features/customers/data/models/customer_update_dto.dart';
import 'package:colloborator_v3/features/customers/data/models/scoring_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:dio/dio.dart';


final class CustomerRemoteDatasource {
  const CustomerRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<List<CustomerInfoDto>> getCustomers(CustomerSearchParams params)async{
    final key = switch (params.kind) {
      CustomerSearchKind.passport => 'passport_series_number',
      CustomerSearchKind.inps => 'inps',
      CustomerSearchKind.fullName => 'fio',
    };

    final result = await _dio.get<Map<String, dynamic>>(Endpoints.getCustomer,queryParameters: {key: params.query, 'page': 1, 'per_page': 30});
  
    return JsonParser.list(result.data?['data'], fromJson: CustomerInfoDto.fromJson);
  }

  Future<CustomerInfoDto?> checkClient(FaceCheckParams params)async{
      final result = await _dio.post<Map<String, dynamic>>(Endpoints.checkClient,data: {
        "passport_series_number": params.passport,
        "birth_date": params.birthday,
        "front": "data:image/png;base64,${await _encodedImage(params.image.path)}"
      });

    return JsonParser.object(result.data?['client'], fromJson: CustomerInfoDto.fromJson);
  }

  Future<ScoringInfoDto?> getScoring(int customerId) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      '${Endpoints.scoringResult}$customerId',
    );

    return JsonParser.object(result.data, fromJson: ScoringInfoDto.fromJson);
  }

  Future<void> updateCustomer(CustomerUpdateParams params) =>
      _dio.put<Map<String, dynamic>>(Endpoints.updateClient, data: CustomerUpdateDto(params).toJson());
}

/// Rasmni o'qish va base64 ga o'girish alohida izolyatda bajariladi — asosiy
/// oqimda bir necha yuz kilobayt kodlash UI ni sekundga qotirib qo'yadi.
Future<String> _encodedImage(String path) => Isolate.run(() => base64Encode(File(path).readAsBytesSync()));
