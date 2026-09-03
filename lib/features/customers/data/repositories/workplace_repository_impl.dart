import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/data/datasources/workplace_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/models/workplace_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_search_params.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/workplace_repository.dart';
import 'package:dio/dio.dart';

final class WorkplaceRepositoryImpl implements WorkplaceRepository {
  const WorkplaceRepositoryImpl({required this._remote});

  final WorkplaceRemoteDatasource _remote;

  @override
  Future<Result<List<WorkplaceInfo>>> search(WorkplaceSearchParams params) async {
    try {
      final List<WorkplaceInfoDto> dto = await _remote.search(params);
      return Ok(dto.map((WorkplaceInfoDto item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}
