import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';

final class GetAvailableTariffsUsecase implements UseCase<List<SpecialTariff>, TariffQuery> {
  const GetAvailableTariffsUsecase(this._repository);

  final SpecialTariffRepository _repository;

  @override
  Future<Result<List<SpecialTariff>>> call(TariffQuery params) => _repository.getAvailable(params);
}

final class ApplyTariffUsecase implements UseCase<void, ApplyTariffParams> {
  const ApplyTariffUsecase(this._repository);

  final SpecialTariffRepository _repository;

  @override
  Future<Result<void>> call(ApplyTariffParams params) => _repository.apply(params);
}

final class RemoveTariffUsecase implements UseCase<void, int> {
  const RemoveTariffUsecase(this._repository);

  final SpecialTariffRepository _repository;

  @override
  Future<Result<void>> call(int params) => _repository.remove(params);
}

final class GetAppliedTariffUsecase implements UseCase<AppliedTariff, int> {
  const GetAppliedTariffUsecase(this._repository);

  final SpecialTariffRepository _repository;

  @override
  Future<Result<AppliedTariff>> call(int params) => _repository.getApplied(params);
}
