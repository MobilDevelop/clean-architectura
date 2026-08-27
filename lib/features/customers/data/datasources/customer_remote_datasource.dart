import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/data/models/customer_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
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
}