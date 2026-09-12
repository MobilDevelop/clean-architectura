import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/special_tariff_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/special_tariff_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';

final class SpecialTariffRepositoryImpl implements SpecialTariffRepository {
  const SpecialTariffRepositoryImpl({required this._remote});

  final SpecialTariffRemoteDatasource _remote;

  @override
  Future<Result<List<SpecialTariff>>> getAvailable(TariffQuery query) => guard(() async {
    final List<SpecialTariffDto> tariffs = await _remote.getAvailable(query);

    return tariffs.map((SpecialTariffDto dto) => dto.toEntity()).toList();
  });

  @override
  Future<Result<void>> apply(ApplyTariffParams params) => guard(() => _remote.apply(params));

  @override
  Future<Result<void>> remove(int contractId) => guard(() => _remote.remove(contractId));

  @override
  Future<Result<AppliedTariff>> getApplied(int contractId) => guard(() async {
    final Map<String, dynamic> tariff = await _remote.getApplied(contractId);

    // Bo'sh obyekt — tarif biriktirilmagan. Bu xato emas.
    return AppliedTariff(
      id: tariff['id'] as int? ?? 0,
      name: tariff['name']?.toString() ?? '',
      isActive: tariff['active'] as bool? ?? false,
    );
  });
}
