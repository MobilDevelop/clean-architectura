import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/katm_skip_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/skip_reason_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/katm_skip_repository.dart';

final class KatmSkipRepositoryImpl implements KatmSkipRepository {
  const KatmSkipRepositoryImpl({required this._remote});

  final KatmSkipRemoteDatasource _remote;

  @override
  Future<Result<List<SkipReason>>> getReasons() => guard(() async {
    final List<SkipReasonDto> reasons = await _remote.getReasons();

    return reasons.map((SkipReasonDto dto) => dto.toEntity()).toList();
  });

  /// Server HTTP 200 bilan `success: false` qaytaradi — `ErrorMapper` buni
  /// ko'rmaydi, shuning uchun shu yerda xatoga aylantiriladi.
  @override
  Future<Result<void>> turnOffKatm(KatmSkipParams params) async {
    final Result<bool> result = await guard(() => _remote.turnOffKatm(params));

    return switch (result) {
      Ok(:final bool value) =>
        value ? const Ok<void>(null) : const Err<void>(ClientFailure('Tekshiruvni o‘chirib bo‘lmadi')),
      Err(:final failure) => Err<void>(failure),
    };
  }
}
