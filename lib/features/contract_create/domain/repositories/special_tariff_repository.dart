import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';

abstract interface class SpecialTariffRepository {
  Future<Result<List<SpecialTariff>>> getAvailable(TariffQuery query);

  Future<Result<void>> apply(ApplyTariffParams params);

  Future<Result<void>> remove(int contractId);

  /// Shartnomaga biriktirilgan tarifni qayta o'qiydi.
  ///
  /// Tovar o'zgargandan keyin kerak: server tarifni o'zi bekor qilishi mumkin
  /// va bu haqda alohida xabar bermaydi.
  Future<Result<AppliedTariff>> getApplied(int contractId);
}
