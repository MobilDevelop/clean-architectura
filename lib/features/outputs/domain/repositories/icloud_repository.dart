import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';

/// Chiqimdan oldin tekshiriladigan iCloud talablari.
abstract interface class IcloudRepository {
  Future<Result<IcloudRequirements>> getRequirements(int contractId);

  Future<Result<void>> saveCredential(IcloudCredential credential);
}
