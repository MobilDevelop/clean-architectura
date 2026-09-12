import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/data/models/address_item_dto.dart';
import 'package:dio/dio.dart';

final class AddressRemoteDatasource {
  const AddressRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<List<AddressItemDto>> getProvinces() async {
    final Response<dynamic> result = await _dio.get<dynamic>(Endpoints.provinces);

    return JsonParser.list(JsonParser.field(result.data, 'data'), fromJson: AddressItemDto.fromJson);
  }

  Future<List<AddressItemDto>> getRegions(int provinceId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.regions,
      queryParameters: <String, dynamic>{'province_id': provinceId},
    );

    return JsonParser.list(JsonParser.field(result.data, 'data'), fromJson: AddressItemDto.fromJson);
  }

  Future<List<AddressItemDto>> getVillages(int regionId) async {
    final Response<dynamic> result = await _dio.get<dynamic>(
      Endpoints.villages,
      queryParameters: <String, dynamic>{'region_id': regionId},
    );

    return JsonParser.list(JsonParser.field(result.data, 'data'), fromJson: AddressItemDto.fromJson);
  }
}
