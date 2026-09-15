part of 'credit_calculator_bloc.dart';

sealed class CreditCalculatorEvent extends Equatable {
  const CreditCalculatorEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class PriceChanged extends CreditCalculatorEvent {
  const PriceChanged(this.price);

  final int price;

  @override
  List<Object?> get props => <Object?>[price];
}

final class TermSelected extends CreditCalculatorEvent {
  const TermSelected(this.termMonths);

  final int termMonths;

  @override
  List<Object?> get props => <Object?>[termMonths];
}

final class FrontMarginChanged extends CreditCalculatorEvent {
  const FrontMarginChanged(this.percent);

  final int percent;

  @override
  List<Object?> get props => <Object?>[percent];
}

final class BackMarginChanged extends CreditCalculatorEvent {
  const BackMarginChanged(this.percent);

  final int percent;

  @override
  List<Object?> get props => <Object?>[percent];
}
