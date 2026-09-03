import 'package:equatable/equatable.dart';

/// Hisobot holati. `notChecked` — xato emas: tekshiruv hali o'tkazilmagan.
enum ReportState { notChecked, available, hasDebt, clean }

enum ParticipantRole { client, guarantor }

/// MIB bo'yicha qisqacha ko'rsatkich — ishtirokchilar ro'yxatida chiqadi.
final class MibSummary extends Equatable {
  const MibSummary({required this.state, required this.total, required this.debtsCount});

  final ReportState state;

  /// So'mda keladi — bo'lish kerak emas.
  final double total;

  final int debtsCount;

  @override
  List<Object?> get props => [state, total, debtsCount];
}

/// KATM bo'yicha qisqacha ko'rsatkich.
final class KatmSummary extends Equatable {
  const KatmSummary({
    required this.state,
    required this.scoringGrade,
    required this.scoringClass,
    required this.scoringLevel,
    required this.hasCreditBan,
    required this.isBlacklisted,
    required this.debtSum,
    required this.overdueSum,
    required this.contractsCount,
  });

  final ReportState state;
  final int scoringGrade;
  final String scoringClass;
  final String scoringLevel;
  final bool hasCreditBan;
  final bool isBlacklisted;
  final double debtSum;
  final double overdueSum;
  final int contractsCount;

  bool get hasWarning => hasCreditBan || isBlacklisted;

  @override
  List<Object?> get props => [
    state,
    scoringGrade,
    scoringClass,
    scoringLevel,
    hasCreditBan,
    isBlacklisted,
    debtSum,
    overdueSum,
    contractsCount,
  ];
}

/// Shartnoma ishtirokchisi: mijoz yoki kafil.
///
/// `clientId` MIB va KATM so'rovlarida `client_id` bo'lib ketadi.
final class CreditParticipant extends Equatable {
  const CreditParticipant({
    required this.clientId,
    required this.role,
    required this.fullName,
    required this.inps,
    required this.mib,
    required this.katm,
  });

  final int clientId;
  final ParticipantRole role;
  final String fullName;
  final String inps;
  final MibSummary mib;
  final KatmSummary katm;

  @override
  List<Object?> get props => [clientId, role, fullName, inps, mib, katm];
}
