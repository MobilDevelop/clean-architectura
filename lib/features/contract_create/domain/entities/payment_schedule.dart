import 'package:equatable/equatable.dart';

/// To'lov jadvalining bitta qatori.
final class ScheduleRow extends Equatable {
  const ScheduleRow({required this.number, required this.date, required this.amount});

  /// To'lov tartib raqami.
  final int number;

  /// To'lov sanasi. Server formati buzilgan bo'lsa `null` — bunday qator
  /// ekranda sanasiz ko'rinadi, lekin yashirilmaydi (5.8).
  final DateTime? date;

  /// Butun so'mda.
  final int amount;

  @override
  List<Object?> get props => [number, date, amount];
}

/// `generate_graphic` javobi.
final class PaymentSchedule extends Equatable {
  const PaymentSchedule(this.rows);

  final List<ScheduleRow> rows;

  bool get isEmpty => rows.isEmpty;

  int get total => rows.fold(0, (int sum, ScheduleRow e) => sum + e.amount);

  /// Oylik to'lov — birinchi qator. Jadval bo'sh bo'lsa `0`.
  int get monthly => rows.isEmpty ? 0 : rows.first.amount;

  @override
  List<Object?> get props => [rows];
}

/// Jadval so'rovi. Muddat va to'lov kuni hali saqlanmagan bo'lishi mumkin —
/// server ularni so'rovdan oladi, qoralamadan emas.
final class ScheduleQuery extends Equatable {
  const ScheduleQuery({
    required this.contractId,
    required this.termMonths,
    required this.paymentDay,
    required this.isInformal,
  });

  final int contractId;
  final int termMonths;
  final int paymentDay;
  final bool isInformal;

  @override
  List<Object?> get props => [contractId, termMonths, paymentDay, isInformal];
}
