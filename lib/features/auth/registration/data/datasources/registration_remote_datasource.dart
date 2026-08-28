import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/services/device_info_service.dart';
import 'package:colloborator_v3/core/services/push_token_service.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/auth/registration/data/models/partner_dto.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/registration_param.dart';
import 'package:dio/dio.dart';

final class RegistrationRemoteDatasource {

  const RegistrationRemoteDatasource({required this._dio, required this._deviceInfo, required this._push});

  final Dio _dio;
  final DeviceInfoService _deviceInfo;
  final PushTokenService _push;

   
  Future<List<PartnerDto>> getPartners(String search)async{

    final response = await _dio.get<Map<String, dynamic>>(Endpoints.partners,queryParameters: {'search': search});

    return JsonParser.list(response.data?['data'], fromJson: PartnerDto.fromJson);
  }

  Future<String> registration(RegistrationParam param)async{
    final device = await _deviceInfo.get();

    final response = await _dio.post<Map<String, dynamic>>(Endpoints.registration,
    data: {
      'partner_id':param.partnerId,
      'fio':param.username,
      'username':param.login,
      'password':param.password,
      'organization_id':param.organizationId,
      'rule_id':2, // hamkor id 2 ekan
      'phone_number':"+${param.phone.replaceAll(RegExp(r'[^0-9]'), '')}",
      'fcm_token':await _push.get(),
      'device_id':device.uniqueId, 
    });

    return  response.data?['message'] as String;
  }
}