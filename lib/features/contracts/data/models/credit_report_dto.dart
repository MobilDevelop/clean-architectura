import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';

/// Backend holatni matn bilan yuboradi.
ReportState reportStateFrom(String? raw) => switch (raw) {
  'not_checked' || null => ReportState.notChecked,
  'has_debt' => ReportState.hasDebt,
  'available' => ReportState.available,
  _ => ReportState.clean,
};

final class MibSummaryDto {
  const MibSummaryDto({required this.state, required this.total, required this.debtsQty});

  factory MibSummaryDto.fromJson(Map<String, dynamic> json) => MibSummaryDto(
    state: json['state'] as String? ?? 'not_checked',
    total: (json['total'] as num? ?? 0).toDouble(),
    debtsQty: json['debts_qty'] as int? ?? 0,
  );

  final String state;
  final double total;
  final int debtsQty;

  MibSummary toEntity() => MibSummary(state: reportStateFrom(state), total: total, debtsCount: debtsQty);
}

final class KatmSummaryDto {
  const KatmSummaryDto({
    required this.state,
    required this.scoringGrade,
    required this.scoringClass,
    required this.scoringLevel,
    required this.creditBan,
    required this.blacklisted,
    required this.allDebtSum,
    required this.allOverdueDebtSum,
    required this.contractsQty,
  });

  factory KatmSummaryDto.fromJson(Map<String, dynamic> json) => KatmSummaryDto(
    state: json['state'] as String? ?? 'not_checked',
    scoringGrade: json['scoring_grade'] as int? ?? 0,
    scoringClass: json['scoring_class'] as String? ?? '',
    scoringLevel: json['scoring_level'] as String? ?? '',
    creditBan: json['credit_ban'] as bool? ?? false,
    blacklisted: json['blacklisted'] as bool? ?? false,
    allDebtSum: (json['all_debt_sum'] as num? ?? 0).toDouble(),
    allOverdueDebtSum: (json['all_overdue_debt_sum'] as num? ?? 0).toDouble(),
    contractsQty: json['contracts_qty'] as int? ?? 0,
  );

  final String state;
  final int scoringGrade;
  final String scoringClass;
  final String scoringLevel;
  final bool creditBan;
  final bool blacklisted;
  final double allDebtSum;
  final double allOverdueDebtSum;
  final int contractsQty;

  KatmSummary toEntity() => KatmSummary(
    state: reportStateFrom(state),
    scoringGrade: scoringGrade,
    scoringClass: scoringClass,
    scoringLevel: scoringLevel,
    hasCreditBan: creditBan,
    isBlacklisted: blacklisted,
    debtSum: allDebtSum,
    overdueSum: allOverdueDebtSum,
    contractsCount: contractsQty,
  );
}

final class CreditParticipantDto {
  const CreditParticipantDto({
    required this.clientId,
    required this.role,
    required this.fio,
    required this.inps,
    required this.mib,
    required this.katm,
  });

  factory CreditParticipantDto.fromJson(Map<String, dynamic> json) => CreditParticipantDto(
    clientId: json['client_id'] as int? ?? 0,
    role: json['role'] as String? ?? '',
    fio: json['fio'] as String? ?? '',
    inps: json['inps'] as String? ?? '',
    mib: MibSummaryDto.fromJson(json['mib'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
    katm: KatmSummaryDto.fromJson(json['katm'] as Map<String, dynamic>? ?? const <String, dynamic>{}),
  );

  final int clientId;
  final String role;
  final String fio;
  final String inps;
  final MibSummaryDto mib;
  final KatmSummaryDto katm;

  CreditParticipant toEntity() => CreditParticipant(
    clientId: clientId,
    role: role == 'client' ? ParticipantRole.client : ParticipantRole.guarantor,
    fullName: fio,
    inps: inps,
    mib: mib.toEntity(),
    katm: katm.toEntity(),
  );
}

/// Javobning tashqi qobig'i: ishtirokchilar ro'yxati shu yerda.
final class CreditReportsDto {
  const CreditReportsDto({required this.participants});

  factory CreditReportsDto.fromJson(Map<String, dynamic> json) => CreditReportsDto(
    participants: JsonParser.list(json['participants'], fromJson: CreditParticipantDto.fromJson),
  );

  final List<CreditParticipantDto> participants;
}
