part of 'credit_calculator_bloc.dart';

final class CreditCalculatorState extends Equatable {
  const CreditCalculatorState({required this.calculation});

  factory CreditCalculatorState.initial() => CreditCalculatorState(calculation: CreditCalculation.initial());

  final CreditCalculation calculation;

  CreditCalculatorState copyWith({CreditCalculation? calculation}) =>
      CreditCalculatorState(calculation: calculation ?? this.calculation);

  @override
  List<Object?> get props => <Object?>[calculation];
}
