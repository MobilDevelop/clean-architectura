import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/auth/registration/data/datasources/registration_remote_datasource.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/registration_param.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/partner.dart';
import 'package:colloborator_v3/features/auth/registration/domain/repositories/registration_repository.dart';
import 'package:dio/dio.dart';

final class RegistrationRepositoryImpl implements RegistrationRepository {
   const RegistrationRepositoryImpl({required this._remote});

   final RegistrationRemoteDatasource _remote;

  @override
  Future<Result<List<Partner>>> getPartners(String search)async{
    try {
      final dto = await _remote.getPartners(search);

      return Ok(dto.map((partner) => partner.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<String>> registration(RegistrationParam param)async{
    try {
      final dto = await _remote.registration(param);

      return Ok(dto);
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}