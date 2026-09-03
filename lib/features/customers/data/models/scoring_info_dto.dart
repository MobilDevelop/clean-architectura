import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';

final class ScoringContractDto {
  const ScoringContractDto({
    required this.id,
    required this.branch,
    required this.status,
    required this.closed,
    required this.date,
    required this.term,
    required this.monthlyPayment,
    required this.totalDebt,
    required this.hasOverdue,
  });

  factory ScoringContractDto.fromJson(Map<String, dynamic> json) => ScoringContractDto(
    id: json['id'] as int,
    branch: json['branch'] as String? ?? '',
    status: json['status'] as String? ?? '',
    closed: json['closed'] as bool? ?? false,
    date: json['date'] as String? ?? '',
    term: json['term'] as int? ?? 0,
    monthlyPayment: json['monthly_payment'] as num? ?? 0,
    totalDebt: json['total_debt'] as num? ?? 0,
    hasOverdue: json['has_overdue'] as bool? ?? false,
  );

  final int id;
  final String branch;
  final String status;
  final bool closed;
  final String date;
  final int term;
  final num monthlyPayment;
  final num totalDebt;
  final bool hasOverdue;

  ScoringContract toEntity() => ScoringContract(
    id: id,
    branch: branch,
    status: status,
    isClosed: closed,
    date: date,
    termMonths: term,
    monthlyPayment: monthlyPayment,
    totalDebt: totalDebt,
    hasOverdue: hasOverdue,
  );
}

/// Backend shakli shu yerda tiplanadi — `Map` toEntity ichida qolib ketmaydi (4.4).
final class ScoringInfoDto {
  const ScoringInfoDto({
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
    required this.closedCount,
    required this.closedSum,
    required this.activeCount,
    required this.activeSum,
    required this.activeMonthly,
    required this.guarantorCount,
    required this.guarantorSum,
    required this.guarantorMonthly,
    required this.activeContracts,
    required this.closedContracts,
    required this.guarantorContracts,
  });

  factory ScoringInfoDto.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> detail = json['contracts_detail'] as Map<String, dynamic>? ?? const <String, dynamic>{};

    List<ScoringContractDto> group(String key) =>
        JsonParser.list(detail[key], fromJson: ScoringContractDto.fromJson);

    return ScoringInfoDto(
      isScored: json['is_scored'] as bool,
      ball: json['ball'] as num,
      guarantorBall: json['guarantor_ball'] as num,
      permissionSum: json['permission_sum'] as num,
      // Rad sababi va avto limiti faqat ayrim holatlarda keladi.
      reason: json['reason'] as String? ?? '',
      carLimit: json['car_limit_message'] as String? ?? '',
      passBlackList: json['pass_black_list_check'] as bool,
      passPaymentGraphics: json['check_payment_graphics'] as bool,
      passPaymentDiscipline: json['check_payment_discipline'] as bool,
      passCriminalRecord: json['check_criminal_record'] as bool,
      closedCount: json['number_of_self_all_closed_contracts'] as int,
      closedSum: json['sum_of_self_all_closed_contracts'] as num,
      activeCount: json['number_of_self_all_active_contracts'] as int,
      activeSum: json['sum_of_self_all_active_contracts'] as num,
      activeMonthly: json['monthly_payment_of_self_all_active_contracts'] as num,
      guarantorCount: json['number_of_guarantor_all_active_contracts'] as int,
      guarantorSum: json['sum_of_guarantor_all_active_contracts'] as num,
      guarantorMonthly: json['monthly_payment_of_guarantor_all_active_contracts'] as num,
      activeContracts: group('self_active'),
      closedContracts: group('self_closed'),
      guarantorContracts: group('guarantor'),
    );
  }

  final bool isScored;
  final num ball;
  final num guarantorBall;
  final num permissionSum;
  final String reason;
  final String carLimit;
  final bool passBlackList;
  final bool passPaymentGraphics;
  final bool passPaymentDiscipline;
  final bool passCriminalRecord;
  final int closedCount;
  final num closedSum;
  final int activeCount;
  final num activeSum;
  final num activeMonthly;
  final int guarantorCount;
  final num guarantorSum;
  final num guarantorMonthly;
  final List<ScoringContractDto> activeContracts;
  final List<ScoringContractDto> closedContracts;
  final List<ScoringContractDto> guarantorContracts;

  ScoringInfo toEntity() => ScoringInfo(
    isScored: isScored,
    ball: ball,
    guarantorBall: guarantorBall,
    permissionSum: permissionSum,
    reason: reason,
    carLimit: carLimit,
    passBlackList: passBlackList,
    passPaymentGraphics: passPaymentGraphics,
    passPaymentDiscipline: passPaymentDiscipline,
    passCriminalRecord: passCriminalRecord,
    // Yopilgan shartnomalarda oylik to'lov yo'q — server bu kalitni yubormaydi.
    closed: ScoringTotals(count: closedCount, sum: closedSum),
    active: ScoringTotals(count: activeCount, sum: activeSum, monthlyPayment: activeMonthly),
    guarantor: ScoringTotals(count: guarantorCount, sum: guarantorSum, monthlyPayment: guarantorMonthly),
    activeContracts: activeContracts.map((ScoringContractDto e) => e.toEntity()).toList(),
    closedContracts: closedContracts.map((ScoringContractDto e) => e.toEntity()).toList(),
    guarantorContracts: guarantorContracts.map((ScoringContractDto e) => e.toEntity()).toList(),
  );
}
