import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contracts_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/models/contract_scoring_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/katm_report_dto.dart';
import 'package:colloborator_v3/features/contracts/data/models/mib_report_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:dio/dio.dart';

final class ContractsRepositoryImpl implements ContractRepository {
  const ContractsRepositoryImpl({required this._remote});

  final ContractsRemoteDatasource _remote;

  @override
  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter)async{
    try {
      final dto = await _remote.getContracts(filter);

      return Ok(dto.map((item) => item.toEntity()).toList());
    }  on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }

  }

  @override
  Future<Result<List<ContractScoring>>> getScoring(int contractId) async {
    try {
      final List<ContractScoringDto> dto = await _remote.getScoring(contractId);

      return Ok(dto.map((ContractScoringDto item) => item.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<List<CreditParticipant>>> getParticipants(int contractId) async {
    try {
      final CreditReportsDto? dto = await _remote.getCreditReports(contractId);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      // `client_id` siz ishtirokchi bo'yicha hisobot so'rab bo'lmaydi —
      // bunday yozuv tanlagichda ham ko'rinmasligi kerak.
      return Ok(
        dto.participants
            .where((CreditParticipantDto item) => item.clientId > 0)
            .map((CreditParticipantDto item) => item.toEntity())
            .toList(),
      );
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<MibReport>> getMib(MibParams params) async {
    try {
      final MibReportDto? dto = await _remote.getMib(params);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<KatmReport>> getKatm(KatmParams params) async {
    try {
      final KatmReportDto? dto = await _remote.getKatm(params);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));

      return Ok(dto.toEntity());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<List<String>>> getFlexMessages(int contractId) async {
    try {
      final List<FlexMessageDto> dto = await _remote.getFlexMessages(contractId);

      return Ok(
        dto
            .map((FlexMessageDto item) => item.message)
            .where((String message) => message.isNotEmpty)
            .toList(),
      );
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}