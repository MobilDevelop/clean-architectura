import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_info_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

final class ContractsRemoteDatasource {
  const ContractsRemoteDatasource({required this._dio, required this._now});

  final Dio _dio;
  final DateTime Function() _now;
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  Future<List<ContractInfoDto>> getContracts(ContractsFilter filter)async{

  final DateTime date = filter.date ?? _now();
  final String formatDate = _formatter.format(date);

   final result = await _dio.get<Map<String, dynamic>>(Endpoints.getContracts,queryParameters: {"page": filter.page,"date":formatDate,'per_page': filter.perPage,"is_mobile" : true});

   return JsonParser.list(result.data?['data'], fromJson: ContractInfoDto.fromJson);
  }

}