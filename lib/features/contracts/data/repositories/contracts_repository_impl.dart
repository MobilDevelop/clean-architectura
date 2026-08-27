import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:dio/dio.dart';

final class ContractsRepositoryImpl implements ContractRepository {
  const ContractsRepositoryImpl({required this._remote});

  final ContractsRemoteDatasource _remote;

  @override
  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter)async{
    try {
      final dto = await _remote.getContracts(filter);

      return Ok(dto.map((item) => item.toEntity()).toList());
    }  on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }

  }
}