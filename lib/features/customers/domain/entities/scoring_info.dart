import 'package:equatable/equatable.dart';

/// Skoring natijasidagi bitta shartnoma.
final class ScoringContract extends Equatable {
  const ScoringContract({
    required this.id,
    required this.branch,
    required this.status,
    required this.isClosed,
    required this.date,
    required this.termMonths,
    required this.monthlyPayment,
    required this.totalDebt,
    required this.hasOverdue,
  });

  final int id;
  final String branch;
  final String status;
  final bool isClosed;
  final String date;
  final int termMonths;
  final num monthlyPayment;
  final num totalDebt;
  final bool hasOverdue;

  @override
  List<Object?> get props => [id, branch, status, isClosed, date, termMonths, monthlyPayment, totalDebt, hasOverdue];
}

/// Bir turdagi shartnomalarning yig'indisi.
final class ScoringTotals extends Equatable {
  const ScoringTotals({required this.count, required this.sum, this.monthlyPayment});

  final int count;
  final num sum;

  /// Yopilgan shartnomalarda oylik to'lov bo'lmaydi — server bu kalitni
  /// yubormaydi. `null` shuni bildiradi, nol emas.
  final num? monthlyPayment;

  @override
  List<Object?> get props => [count, sum, monthlyPayment];
}

final class ScoringInfo extends Equatable {
  const ScoringInfo({
    required this.isScored,
    required this.ball,
    required this.guarantorBall,
    required this.permissionSum,
    required this.reason,
    required this.carLimit,
    required this.passBlackList,
    required this.passPaymentGraphics,
    required this.passPaymentDiscipline,
    required this.passCriminalRecord,
    required this.closed,
    required this.active,
    required this.guarantor,
    required this.activeContracts,
    required this.closedContracts,
    required this.guarantorContracts,
  });

  final bool isScored;
  final num ball;
  final num guarantorBall;

  /// Ruxsat etilgan summa.
  final num permissionSum;

  /// Rad etilgan bo'lsa sababi. Bo'sh bo'lishi mumkin.
  final String reason;

  /// Avto limiti haqidagi xabar. Bo'sh bo'lishi mumkin.
  final String carLimit;

  final bool passBlackList;
  final bool passPaymentGraphics;
  final bool passPaymentDiscipline;
  final bool passCriminalRecord;

  final ScoringTotals closed;
  final ScoringTotals active;
  final ScoringTotals guarantor;

  final List<ScoringContract> activeContracts;
  final List<ScoringContract> closedContracts;
  final List<ScoringContract> guarantorContracts;

  /// Barcha tekshiruvlardan o'tganmi — ekranda umumiy holat shundan.
  bool get isClean => passBlackList && passPaymentGraphics && passPaymentDiscipline && passCriminalRecord;

  @override
  List<Object?> get props => [
    isScored,
    ball,
    guarantorBall,
    permissionSum,
    reason,
    carLimit,
    passBlackList,
    passPaymentGraphics,
    passPaymentDiscipline,
    passCriminalRecord,
    closed,
    active,
    guarantor,
    activeContracts,
    closedContracts,
    guarantorContracts,
  ];
}
