import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/data/datasources/icloud_remote_datasource.dart';
import 'package:colloborator_v3/features/outputs/data/models/icloud_requirement_dto.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/icloud_repository.dart';

final class IcloudRepositoryImpl implements IcloudRepository {
  const IcloudRepositoryImpl({required this._remote});

  final IcloudRemoteDatasource _remote;

  /// Javob o'qilmasa `Err` qaytadi (4.7.4): bo'sh talab ro'yxati «hammasi
  /// to'ldirilgan» degan ma'noni berib, chiqimni noto'g'ri ochib yuborardi.
  @override
  Future<Result<IcloudRequirements>> getRequirements(int contractId) => guard(() async {
    final IcloudRequirementsDto? dto = await _remote.getRequirements(contractId);

    if (dto == null) throw const FormatException('iCloud talablari javobi obyekt emas');

    return dto.toEntity();
  });

  @override
  Future<Result<void>> saveCredential(IcloudCredential credential) =>
      guard(() => _remote.saveCredential(credential));
}
