import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';

/// Testlar uchun soxta tarif repositoryi.
final class FakeSpecialTariffRepository implements SpecialTariffRepository {
  Result<List<SpecialTariff>> availableResult = const Ok<List<SpecialTariff>>(<SpecialTariff>[]);
  Result<void> applyResult = const Ok<void>(null);
  Result<void> removeResult = const Ok<void>(null);
  Result<AppliedTariff> appliedResult = const Ok<AppliedTariff>(
    AppliedTariff(id: 0, name: '', isActive: false),
  );

  int removeCalls = 0;

  @override
  Future<Result<List<SpecialTariff>>> getAvailable(TariffQuery query) async => availableResult;

  @override
  Future<Result<void>> apply(ApplyTariffParams params) async => applyResult;

  @override
  Future<Result<void>> remove(int contractId) async {
    removeCalls++;

    return removeResult;
  }

  @override
  Future<Result<AppliedTariff>> getApplied(int contractId) async => appliedResult;
}
