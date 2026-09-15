import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/change_password/data/datasources/change_password_remote_datasource.dart';
import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';
import 'package:colloborator_v3/features/change_password/domain/repositories/change_password_repository.dart';

final class ChangePasswordRepositoryImpl implements ChangePasswordRepository {
  const ChangePasswordRepositoryImpl({required this._remote});

  final ChangePasswordRemoteDatasource _remote;

  @override
  Future<Result<void>> changePassword(ChangePasswordParams params) => guard(() => _remote.changePassword(params));
}
