import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/data/models/workplace_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_search_params.dart';
import 'package:dio/dio.dart';

final class WorkplaceRemoteDatasource {
  const WorkplaceRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<List<WorkplaceInfoDto>> search(WorkplaceSearchParams params) async {
    final Response<Map<String, dynamic>> result = await _dio.get<Map<String, dynamic>>(
      Endpoints.workplaces,
      queryParameters: <String, dynamic>{'region_id': params.regionId, 'search': params.query},
    );

    return JsonParser.list(result.data?['data'], fromJson: WorkplaceInfoDto.fromJson);
  }
}
