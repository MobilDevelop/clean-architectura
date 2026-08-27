import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/auth/login/data/datasources/auth_remote_datasource.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';
import 'package:colloborator_v3/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// `AuthRepository` shartnomasining tarmoq orqali bajarilishi.
/// Yagona vazifasi — datasource'ni chaqirish va istisnolarni `Failure` ga o'girish.
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Result<AuthSession>> login(LoginParams params) async {
    try {
      final dto = await _remote.login(params);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remote.logout();

      return const Ok<void>(null);
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}