import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';

abstract interface class ContractRepository {

  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter);
}