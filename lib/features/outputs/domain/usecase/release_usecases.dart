import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/output_release_repository.dart';

final class ConfirmReleaseUsecase implements UseCase<void, ReleaseParams> {
  const ConfirmReleaseUsecase(this._repository);

  final OutputReleaseRepository _repository;

  @override
  Future<Result<void>> call(ReleaseParams params) => _repository.confirmRelease(params);
}

final class ReturnProductsUsecase implements UseCase<void, ProductReturnParams> {
  const ReturnProductsUsecase(this._repository);

  final OutputReleaseRepository _repository;

  /// Bo'sh ro'yxat serverga ketmaydi: u shartnomani o'zgartirmaydi, lekin
  /// javobi muvaffaqiyat bo'lgani uchun ekran «qaytarildi» deb ko'rsatardi
  /// (5.8).
  @override
  Future<Result<void>> call(ProductReturnParams params) async {
    if (params.productIds.isEmpty) {
      return const Err<void>(ClientFailure('Qaytariladigan tovar tanlanmagan'));
    }

    return _repository.returnProducts(params);
  }
}
