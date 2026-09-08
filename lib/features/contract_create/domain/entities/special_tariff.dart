import 'package:equatable/equatable.dart';

/// Shartnomaga biriktirilishi mumkin bo'lgan maxsus tarif.
final class SpecialTariff extends Equatable {
  const SpecialTariff({
    required this.id,
    required this.name,
    required this.frontMargin,
    required this.prepaymentPercent,
    required this.quarters,
    required this.startsAt,
    required this.endsAt,
  });

  final int id;
  final String name;

  /// Oldingi marja, foizda.
  final double frontMargin;

  /// Boshlang'ich to'lov foizi.
  final double prepaymentPercent;

  /// To'rt choraklik marja — tartibda: 1, 2, 3, 4.
  final List<double> quarters;

  /// Amal qilish muddati. Server formatlangan satr yuboradi.
  final String startsAt;
  final String endsAt;

  @override
  List<Object?> get props => [id, name, frontMargin, prepaymentPercent, quarters, startsAt, endsAt];
}

final class ApplyTariffParams extends Equatable {
  const ApplyTariffParams({required this.contractId, required this.tariffId, required this.termMonths});

  final int contractId;
  final int tariffId;
  final int termMonths;

  @override
  List<Object?> get props => [contractId, tariffId, termMonths];
}

final class TariffQuery extends Equatable {
  const TariffQuery({required this.contractId, required this.termMonths});

  final int contractId;
  final int termMonths;

  @override
  List<Object?> get props => [contractId, termMonths];
}
