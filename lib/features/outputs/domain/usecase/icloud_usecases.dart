import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/icloud_repository.dart';

final class GetIcloudRequirementsUsecase implements UseCase<IcloudRequirements, int> {
  const GetIcloudRequirementsUsecase(this._repository);

  final IcloudRepository _repository;

  @override
  Future<Result<IcloudRequirements>> call(int params) => _repository.getRequirements(params);
}

final class SaveIcloudCredentialUsecase implements UseCase<void, IcloudCredential> {
  const SaveIcloudCredentialUsecase(this._repository);

  final IcloudRepository _repository;

  /// To'ldirilmagan forma serverga ketmaydi: server uni baribir rad etadi,
  /// lekin javobi umumiy bo'lgani uchun qaysi maydon ekani bilinmasdi.
  @override
  Future<Result<void>> call(IcloudCredential params) async {
    if (params.issue != IcloudIssue.none) {
      return const Err<void>(ClientFailure("Ma'lumotlar to'liq emas"));
    }

    return _repository.saveCredential(params);
  }
}
