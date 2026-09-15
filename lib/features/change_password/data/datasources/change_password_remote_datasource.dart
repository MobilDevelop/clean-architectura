import 'package:colloborator_v3/core/network/endpoints.dart';
import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';
import 'package:dio/dio.dart';

final class ChangePasswordRemoteDatasource {
  const ChangePasswordRemoteDatasource({required this._dio});

  final Dio _dio;

  Future<void> changePassword(ChangePasswordParams params) => _dio.put<dynamic>(
    Endpoints.updatePassword,
    data: <String, dynamic>{'password': params.password},
  );
}
