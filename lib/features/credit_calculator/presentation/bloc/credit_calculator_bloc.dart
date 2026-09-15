import 'package:colloborator_v3/features/credit_calculator/domain/entities/credit_calculation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'credit_calculator_event.dart';
part 'credit_calculator_state.dart';

/// Kredit kalkulyator. Serverga murojaat qilmaydi — hammasi
/// `CreditCalculation` ning hisoblangan maydonlarida (3.8).
final class CreditCalculatorBloc extends Bloc<CreditCalculatorEvent, CreditCalculatorState> {
  CreditCalculatorBloc() : super(CreditCalculatorState.initial()) {
    on<PriceChanged>(
      (PriceChanged event, Emitter<CreditCalculatorState> emit) =>
          emit(state.copyWith(calculation: state.calculation.copyWith(price: event.price))),
    );

    on<TermSelected>(
      (TermSelected event, Emitter<CreditCalculatorState> emit) =>
          emit(state.copyWith(calculation: state.calculation.copyWith(termMonths: event.termMonths))),
    );

    on<FrontMarginChanged>(
      (FrontMarginChanged event, Emitter<CreditCalculatorState> emit) =>
          emit(state.copyWith(calculation: state.calculation.copyWith(frontMarginPercent: event.percent))),
    );

    on<BackMarginChanged>(
      (BackMarginChanged event, Emitter<CreditCalculatorState> emit) =>
          emit(state.copyWith(calculation: state.calculation.copyWith(backMarginPercent: event.percent))),
    );
  }
}
