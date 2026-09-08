import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';

abstract interface class ContractGuarantorRepository {
  /// Kafil qo'shadi va server qaytargan id ni beradi.
  Future<Result<int>> addGuarantor(AddGuarantorParams params);

  Future<Result<void>> removeGuarantor(RemoveGuarantorParams params);
}
