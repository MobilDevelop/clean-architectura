import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:equatable/equatable.dart';

final class CardConfirmState extends Equatable {
  const CardConfirmState({
    required this.contractId,
    required this.isLoading,
    required this.isSubmitting,
    required this.isSkipCard,
    required this.code,
    required this.entry,
    required this.isDone,
    this.data,
    this.failure,
  });

  const CardConfirmState.initial(this.contractId)
    : isLoading = false,
      isSubmitting = false,
      isSkipCard = false,
      code = '',
      entry = const CardEntry.empty(),
      isDone = false,
      data = null,
      failure = null;

  final int contractId;

  final bool isLoading;
  final bool isSubmitting;

  /// «Plastik karta tekshirilmasin» belgilangan.
  final bool isSkipCard;

  final String code;
  final CardEntry entry;

  /// Server amalni qabul qildi — oyna yopiladi va ro'yxat yangilanadi.
  final bool isDone;

  /// Serverdagi holat. `null` — hali o'qilmagan.
  final CardConfirmation? data;

  final Failure? failure;

  bool get isBusy => isLoading || isSubmitting;

  /// Karta ma'lumoti so'ralayotgan bosqich.
  bool get needsCard => data?.step == CardConfirmStep.cardNeeded && !isSkipCard;

  /// Tugma bosilganda qaysi amal ketadi.
  ///
  /// Nega state'da: bir tugmaning ma'nosi uchta va uni ekran ham, bloc ham
  /// bir xil tushunishi kerak.
  CardConfirmAction get action {
    if (isSkipCard) return CardConfirmAction.skipCard;
    if (data?.step == CardConfirmStep.cardNeeded) return CardConfirmAction.saveCard;

    return CardConfirmAction.code;
  }

  CardConfirmState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? isSkipCard,
    String? code,
    CardEntry? entry,
    bool? isDone,
    CardConfirmation? data,
    Failure? failure,
    bool clearFailure = false,
  }) => CardConfirmState(
    contractId: contractId,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSkipCard: isSkipCard ?? this.isSkipCard,
    code: code ?? this.code,
    entry: entry ?? this.entry,
    isDone: isDone ?? this.isDone,
    data: data ?? this.data,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    contractId,
    isLoading,
    isSubmitting,
    isSkipCard,
    code,
    entry,
    isDone,
    data,
    failure,
  ];
}
