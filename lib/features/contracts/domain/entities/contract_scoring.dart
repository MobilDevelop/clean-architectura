import 'package:equatable/equatable.dart';

/// Ichki tekshiruv turi. Backend faqat matn qaytaradi, natija bayrog'ini emas.
enum InternalCheckKind { age, blacklist, criminalRecord, clientScore }

/// Tashqi manba.
enum ExternalSource { mib, misoki, kiats, asoki, gnkSalary, pension, cardTurnover, nibbd }

/// Bitta ichki tekshiruv natijasi.
final class InternalCheck extends Equatable {
  const InternalCheck({required this.kind, required this.detail});

  final InternalCheckKind kind;

  /// Backend qaytargan matn. Bo'sh bo'lishi mumkin.
  final String detail;

  /// **Taxmin.** Backend o'tgan/o'tmaganlik bayrog'ini bermaydi, faqat matn.
  /// Matn shakli o'zgarsa barcha tekshiruvlar "o'tmadi" bo'lib ko'rinadi —
  /// javobga `failed` maydoni qo'shilgach shu getter o'rniga o'sha ishlatiladi.
  bool get isPassed => detail.contains('Muvaffaqiyatli');

  @override
  List<Object?> get props => [kind, detail];
}

/// Tashqi tekshiruvni rad etish sababi.
final class StopReason extends Equatable {
  const StopReason({required this.statusCode, required this.code, required this.description});

  final String statusCode;
  final String code;
  final String description;

  @override
  List<Object?> get props => [statusCode, code, description];
}

/// Bitta tashqi manba bo'yicha natija.
final class ExternalCheck extends Equatable {
  const ExternalCheck({
    required this.source,
    required this.code,
    required this.nameUz,
    required this.nameRu,
    required this.descriptionUz,
    required this.descriptionRu,
    required this.reasons,
  });

  final ExternalSource source;
  final String code;

  // Ikkala til ham saqlanadi: tarjimaga o'tilganda sahifa o'zi tanlaydi.
  final String nameUz;
  final String nameRu;
  final String descriptionUz;
  final String descriptionRu;

  final List<StopReason> reasons;

  bool get hasReasons => reasons.isNotEmpty;

  @override
  List<Object?> get props => [source, code, nameUz, nameRu, descriptionUz, descriptionRu, reasons];
}

/// Bitta ishtirokchining limiti.
final class ScoringLimits extends Equatable {
  const ScoringLimits({
    required this.total,
    required this.free,
    required this.exceeded,
    required this.coBorrower,
    required this.asokiMonthlyPayment,
  });

  final int total;
  final int free;

  /// Yetmayotgan limit. Noldan katta bo'lsa shartnoma limitga sig'maydi.
  final int exceeded;

  final int coBorrower;
  final int asokiMonthlyPayment;

  /// Limitning band qilingan ulushi, 0..1.
  double get usedShare => total <= 0 ? 0 : ((total - free) / total).clamp(0, 1);

  @override
  List<Object?> get props => [total, free, exceeded, coBorrower, asokiMonthlyPayment];
}

/// Shartnoma bo'yicha bitta ishtirokchining (mijoz yoki kafil) skoring natijasi.
///
/// Server ro'yxat qaytaradi: har bir ishtirokchi uchun bitta yozuv.
final class ContractScoring extends Equatable {
  const ContractScoring({
    required this.clientId,
    required this.clientName,
    required this.statusCode,
    required this.limits,
    required this.internal,
    required this.external,
  });

  final int clientId;
  final String clientName;
  final String statusCode;
  final ScoringLimits limits;
  final List<InternalCheck> internal;
  final List<ExternalCheck> external;

  int get passedInternal => internal.where((InternalCheck check) => check.isPassed).length;

  @override
  List<Object?> get props => [clientId, clientName, statusCode, limits, internal, external];
}
