import 'dart:io';

import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/services/device_info_service.dart';
import 'package:colloborator_v3/core/services/push_token_service.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/auth/login/data/models/auth_response_dto.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';
import 'package:dio/dio.dart';

/// Auth uchun tarmoq chaqiruvlari.
/// Bu yerda xato tutilmaydi — `DioException` repository'ga chiqadi
/// va u yerda `Failure` ga aylanadi.
final class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required this._dio,
    required this._deviceInfo,
    required this._push,
  });

  final Dio _dio;
  final DeviceInfoService _deviceInfo;
  final PushTokenService _push;

  Future<AuthResponseDto?> login(LoginParams params) async {
    final device = await _deviceInfo.get();

    final response = await _dio.post<Map<String, dynamic>>(
      Endpoints.login,
      data: {
        'username': params.username,
        'password': params.password,
        'is_web': false,
        'new_version': true,
        //'device_id': device.uniqueId,
        'device_id': "aa2ad6bb11fcdefd",
        'device_name': device.name,
        'device_model': device.brand,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'os_version': device.osVersion,
        'fcm_token': await _push.get(),
      },
    );

    return JsonParser.object(response.data,fromJson: AuthResponseDto.fromJson);
  }

  Future<void> logout() => _dio.post<void>(Endpoints.logOut);

}