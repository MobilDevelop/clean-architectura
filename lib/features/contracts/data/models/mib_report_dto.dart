import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';

final class MibDebtDto {
  const MibDebtDto({
    required this.position,
    required this.date,
    required this.workNumber,
    required this.docContent,
    required this.branchName,
    required this.branchPhone,
    required this.creditorName,
    required this.amount,
  });

  factory MibDebtDto.fromJson(Map<String, dynamic> json) => MibDebtDto(
    position: json['position'] as int? ?? 0,
    date: json['date'] as String? ?? '',
    workNumber: json['work_number'] as String? ?? '',
    docContent: json['doc_content'] as String? ?? '',
    branchName: json['branch_name'] as String? ?? '',
    branchPhone: json['branch_phone'] as String? ?? '',
    creditorName: json['creditor_name'] as String? ?? '',
    amount: (json['amount'] as num? ?? 0).toDouble(),
  );

  final int position;
  final String date;
  final String workNumber;
  final String docContent;
  final String branchName;
  final String branchPhone;
  final String creditorName;
  final double amount;

  MibDebt toEntity() => MibDebt(
    position: position,
    date: date,
    workNumber: workNumber,
    content: docContent,
    branchName: branchName,
    branchPhone: branchPhone,
    creditorName: creditorName,
    amount: amount,
  );
}

/// `not_checked` holatida javobda faqat bir nechta maydon keladi — qolgani
/// bo'sh qoladi va bu xato emas.
final class MibReportDto {
  const MibReportDto({
    required this.state,
    required this.title,
    required this.headline,
    required this.debtorName,
    required this.inps,
    required this.total,
    required this.current,
    required this.registry,
    required this.resultMessage,
    required this.debts,
    required this.scoredAt,
  });

  factory MibReportDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> totals = json['totals'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    return MibReportDto(
      state: json['state'] as String? ?? 'not_checked',
      title: json['title'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      debtorName: json['debtor_name'] as String? ?? '',
      inps: json['inps'] as String? ?? '',
      // Uchala summa so'mda keladi.
      total: (totals['total'] as num? ?? 0).toDouble(),
      current: (totals['current'] as num? ?? 0).toDouble(),
      registry: (totals['registry'] as num? ?? 0).toDouble(),
      resultMessage: json['result_message'] as String? ?? '',
      debts: JsonParser.list(json['debts'], fromJson: MibDebtDto.fromJson),
      scoredAt: json['scored_at'] as String? ?? '',
    );
  }

  final String state;
  final String title;
  final String headline;
  final String debtorName;
  final String inps;
  final double total;
  final double current;
  final double registry;
  final String resultMessage;
  final List<MibDebtDto> debts;
  final String scoredAt;

  MibReport toEntity() => MibReport(
    state: reportStateFrom(state),
    title: title,
    headline: headline,
    debtorName: debtorName,
    inps: inps,
    totals: MibTotals(total: total, current: current, registry: registry),
    resultMessage: resultMessage,
    debts: debts.map((MibDebtDto dto) => dto.toEntity()).toList(),
    scoredAt: scoredAt,
  );
}
