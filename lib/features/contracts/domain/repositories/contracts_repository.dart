import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';

abstract interface class ContractRepository {

  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter);
  Future<Result<List<ContractScoring>>> getScoring(int contractId);

  /// Faqat flex shartnomalari uchun. Xabar bo'lmasa bo'sh ro'yxat.
  Future<Result<List<String>>> getFlexMessages(int contractId);

  Future<Result<List<CreditParticipant>>> getParticipants(int contractId);
  Future<Result<MibReport>> getMib(MibParams params);
  Future<Result<KatmReport>> getKatm(KatmParams params);
}