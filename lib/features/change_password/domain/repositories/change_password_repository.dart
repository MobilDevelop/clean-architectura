import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/change_password/domain/entities/change_password_params.dart';

abstract interface class ChangePasswordRepository {
  Future<Result<void>> changePassword(ChangePasswordParams params);
}
