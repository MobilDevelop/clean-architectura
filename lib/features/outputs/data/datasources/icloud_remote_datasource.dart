import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/outputs/data/models/icloud_requirement_dto.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:dio/dio.dart';

final class IcloudRemoteDatasource {
  const IcloudRemoteDatasource({required this._dio});

  final Dio _dio;

  /// Javob shakli mos kelmasa `null` qaytadi — repository buni `Failure` ga
  /// o'giradi.
  ///
  /// So'rov `dynamic` bilan yuboriladi: `get<Map<String, dynamic>>` javob
  /// boshqa shaklda kelganda Dio ichida, interceptor zanjiridan **keyin**
  /// yiqiladi va nosozlik botga yetib bormaydi.
  Future<IcloudRequirementsDto?> getRequirements(int contractId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.icloudRequirements,
      queryParameters: <String, dynamic>{'contract_id': contractId},
    );

    return JsonParser.object(result.data, fromJson: IcloudRequirementsDto.fromJson);
  }

  Future<void> saveCredential(IcloudCredential credential) async {
    await _dio.post<dynamic>(Endpoints.icloudContracts, data: IcloudCredentialBody.of(credential));
  }
}
