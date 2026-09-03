import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:equatable/equatable.dart';

/// Bitta ijro hujjati.
final class MibDebt extends Equatable {
  const MibDebt({
    required this.position,
    required this.date,
    required this.workNumber,
    required this.content,
    required this.branchName,
    required this.branchPhone,
    required this.creditorName,
    required this.amount,
  });

  final int position;
  final String date;
  final String workNumber;
  final String content;
  final String branchName;
  final String branchPhone;
  final String creditorName;

  /// So'mda keladi.
  final double amount;

  @override
  List<Object?> get props => [position, date, workNumber, content, branchName, branchPhone, creditorName, amount];
}

final class MibTotals extends Equatable {
  const MibTotals({required this.total, required this.current, required this.registry});

  final double total;
  final double current;
  final double registry;

  @override
  List<Object?> get props => [total, current, registry];
}

/// MIB ijro hujjatlari hisoboti.
///
/// `notChecked` — server `200` bilan qaytaradigan qonuniy holat, xato emas.
final class MibReport extends Equatable {
  const MibReport({
    required this.state,
    required this.title,
    required this.headline,
    required this.debtorName,
    required this.inps,
    required this.totals,
    required this.resultMessage,
    required this.debts,
    required this.scoredAt,
  });

  final ReportState state;
  final String title;
  final String headline;
  final String debtorName;
  final String inps;
  final MibTotals totals;
  final String resultMessage;
  final List<MibDebt> debts;
  final String scoredAt;

  bool get isChecked => state != ReportState.notChecked;

  bool get hasDebt => state == ReportState.hasDebt;

  @override
  List<Object?> get props => [state, title, headline, debtorName, inps, totals, resultMessage, debts, scoredAt];
}

/// MIB so'rovi ikkita raqamga bog'liq — shuning uchun param obyekti (3.3).
final class MibParams extends Equatable {
  const MibParams({required this.contractId, required this.clientId});

  final int contractId;
  final int clientId;

  @override
  List<Object?> get props => [contractId, clientId];
}
