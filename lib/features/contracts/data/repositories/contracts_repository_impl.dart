import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_authority_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_scoring_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/katm_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/mib_report_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class ContractsRepositoryImpl implements ContractRepository {
  const ContractsRepositoryImpl({required this._remote});

  final ContractsRemoteDatasource _remote;

  @override
  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter) => guard(() async {
      final dto = await _remote.getContracts(filter);

      return dto.map((item) => item.toEntity()).toList();

  });

  @override
  Future<Result<List<ContractScoring>>> getScoring(int contractId) => guard(() async {
      final List<ContractScoringDto> dto = await _remote.getScoring(contractId);

      return dto.map((ContractScoringDto item) => item.toEntity()).toList();
  });

  @override
  Future<Result<List<CreditParticipant>>> getParticipants(int contractId) => guard(() async {
      final CreditReportsDto? dto = await _remote.getCreditReports(contractId);

      if (dto == null) throw const FormatException('javob obyekt emas');

      // `client_id` siz ishtirokchi bo'yicha hisobot so'rab bo'lmaydi —
      // bunday yozuv tanlagichda ham ko'rinmasligi kerak.
      return dto.participants
          .where((CreditParticipantDto item) => item.clientId > 0)
          .map((CreditParticipantDto item) => item.toEntity())
          .toList();
  });

  @override
  Future<Result<MibReport>> getMib(MibParams params) => guard(() async {
      final MibReportDto? dto = await _remote.getMib(params);

      if (dto == null) throw const FormatException('javob obyekt emas');

      return dto.toEntity();
  });

  @override
  Future<Result<KatmReport>> getKatm(KatmParams params) => guard(() async {
      final KatmReportDto? dto = await _remote.getKatm(params);

      if (dto == null) throw const FormatException('javob obyekt emas');

      return dto.toEntity();
  });

  @override
  Future<Result<ContractAuthority>> getAuthority(int contractId) => guard(() async {
      final ContractAuthorityDto? dto = await _remote.getAuthority(contractId);

      if (dto == null) throw const FormatException('javob obyekt emas');

      return dto.toEntity();
  });

  @override
  Future<Result<void>> confirmAuthority(int contractId) => _run(() => _remote.confirmAuthority(contractId));

  @override
  Future<Result<void>> escalateAuthority(int contractId) => _run(() => _remote.escalateAuthority(contractId));

  @override
  Future<Result<void>> allowConfirmation(int contractId) => _run(() => _remote.allowConfirmation(contractId));

  @override
  Future<Result<void>> cancelContract(int contractId) => _run(() => _remote.cancelContract(contractId));

  /// Javob tanasi kerak bo'lmagan amallar bir xil yo'ldan o'tadi.
  Future<Result<void>> _run(Future<void> Function() action) => guard(() async {
      await action();
      return;
  });

  @override
  Future<Result<List<String>>> getFlexMessages(int contractId) => guard(() async {
      final List<FlexMessageDto> dto = await _remote.getFlexMessages(contractId);

      return dto
          .map((FlexMessageDto item) => item.message)
          .where((String message) => message.isNotEmpty)
          .toList();
  });
}