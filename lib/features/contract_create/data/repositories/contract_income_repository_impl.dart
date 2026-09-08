import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/data/datasources/contract_income_remote_datasource.dart';
import 'package:colloborator_v3/features/contract_create/data/models/occupation_dto.dart';
import 'package:colloborator_v3/features/contract_create/data/repositories/result_guard.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_income_repository.dart';

final class ContractIncomeRepositoryImpl implements ContractIncomeRepository {
  const ContractIncomeRepositoryImpl({required this._remote});

  final ContractIncomeRemoteDatasource _remote;

  // O'girish `guard` ichida: buzuq javobda otilgan istisno repositorydan
  // chiqib ketmasligi kerak (5.5).
  @override
  Future<Result<OccupationCatalog>> getOccupations() => guard(() async {
    final OccupationCatalogDto? dto = await _remote.getOccupations();

    // Javob kelmasa ro'yxat bo'sh, lekin bu xato emas: server kasb turini
    // umuman so'ramasligi mumkin.
    return dto?.toEntity() ?? const OccupationCatalog.empty();
  });

  @override
  Future<Result<int>> addCard(AddCardParams params) async =>
      requireValue(await guard(() => _remote.addCard(params)));

  @override
  Future<Result<void>> removeCard(RemoveCardParams params) => guard(() => _remote.removeCard(params));
}
