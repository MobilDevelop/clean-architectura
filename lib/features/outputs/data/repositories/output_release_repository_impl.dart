import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/output_release_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/output_release_repository.dart';

final class OutputReleaseRepositoryImpl implements OutputReleaseRepository {
  const OutputReleaseRepositoryImpl({required this._remote});

  final OutputReleaseRemoteDatasource _remote;

  @override
  Future<Result<void>> confirmRelease(ReleaseParams params) =>
      guard(() => _remote.confirmRelease(params));

  @override
  Future<Result<void>> returnProducts(ProductReturnParams params) =>
      guard(() => _remote.returnProducts(params));
}
