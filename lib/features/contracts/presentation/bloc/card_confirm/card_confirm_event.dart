import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:equatable/equatable.dart';

sealed class CardConfirmEvent extends Equatable {
  const CardConfirmEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Holat so'raldi.
final class CardConfirmRequested extends CardConfirmEvent {
  const CardConfirmRequested();
}

final class CodeChanged extends CardConfirmEvent {
  const CodeChanged(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}

/// «Plastik karta tekshirilmasin» belgisi.
final class SkipCardToggled extends CardConfirmEvent {
  const SkipCardToggled();
}

/// Karta ma'lumoti to'ldirildi.
final class CardEntryChanged extends CardConfirmEvent {
  const CardEntryChanged(this.entry);

  final CardEntry entry;

  @override
  List<Object?> get props => <Object?>[entry];
}

/// Tugma bosildi. Qaysi amal ketishini bloc holatdan hisoblaydi.
final class CardConfirmSubmitted extends CardConfirmEvent {
  const CardConfirmSubmitted();
}

/// Kodni qayta yuborish.
final class CodeResendRequested extends CardConfirmEvent {
  const CodeResendRequested();
}

final class FailureHandled extends CardConfirmEvent {
  const FailureHandled();
}

final class Retried extends CardConfirmEvent {
  const Retried();
}
