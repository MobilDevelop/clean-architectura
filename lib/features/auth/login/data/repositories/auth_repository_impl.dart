import 'dart:convert';

import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/secure_user_storage.dart';
import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:colloborator_v3/features/auth/login/data/datasources/auth_remote_datasource.dart';
import 'package:colloborator_v3/features/auth/login/data/models/user_dto.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';
import 'package:colloborator_v3/features/auth/login/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';

/// `AuthRepository` shartnomasining tarmoq orqali bajarilishi.
/// Yagona vazifasi — datasource'ni chaqirish va istisnolarni `Failure` ga o'girish.
final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._userStorage);

  final AuthRemoteDataSource _remote;
  final SecureUserStorage _userStorage;
  static const String _wrongCredentials = "Login yoki parol noto'g'ri";

  @override
  Future<Result<AuthSession>> login(LoginParams params) async {
    try {
      final dto = await _remote.login(params);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      // Ilova qayta ochilganda tarmoqsiz tiklash uchun. Yozib bo'lmasa ham
      // kirish muvaffaqiyatli hisoblanadi — keyingi safar qayta login kerak
      // bo'ladi, xolos. Sabab yo'qolmasin deb botga xabar beriladi (5.8).
      try {
        await _userStorage.save(jsonEncode(dto.userJson));
      } catch (error, trace) {
        GuardReport.reporter?.call(
          const UnknownFailure('Foydalanuvchi profilini saqlab bo\'lmadi'),
          error,
          trace,
        );
      }

      return Ok(dto.toEntity());
    } on DioException catch (e) {
      final failure = ErrorMapper.fromDio(e);

      if (failure is UnauthorizedFailure) return const Err(ClientFailure(_wrongCredentials, statusCode: 401));
      return Err(failure);

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

  @override
  Future<Result<User?>> restoreSession() async {
    try {
      final String? raw = await _userStorage.read();
      if (raw == null || raw.isEmpty) return const Ok<User?>(null);

      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        await _userStorage.delete();
        return const Ok<User?>(null);
      }

      return Ok<User?>(UserDto.fromJson(decoded).toEntity());
    } catch (error, trace) {
      // Buzuq yozuv xato emas — profil topilmagan deb hisoblanadi va xodim
      // baribir qayta login qilishi mumkin (`AddressRepositoryImpl` bilan
      // bir xil mantiq). Yozuv o'sha zahoti o'chiriladi, aks holda u har
      // ochilishda qayta o'qilib, har safar bekorga urinib qolardi.
      await _userStorage.delete();
      GuardReport.reporter?.call(
        const UnknownFailure('Saqlangan profilni o\'qib bo\'lmadi'),
        error,
        trace,
      );

      return const Ok<User?>(null);
    }
  }
}