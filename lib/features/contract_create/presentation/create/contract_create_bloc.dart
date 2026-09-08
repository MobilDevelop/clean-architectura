import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_create_event.dart';
part 'contract_create_state.dart';

/// Shartnoma yozuvining o'zi: muddat, to'lov kuni, daromad asosi va
/// skoringga yuborish.
///
/// Tovar, kafil va karta — alohida resurs, ularning har biri o'z blocida
/// yoziladi. Bu bloc ularni bilmaydi: o'zgarish bo'lgach `ContractRequested`
/// bilan shartnomani qayta o'qiydi, xolos. Shu sababli yangi resurs
/// qo'shilganda bu bloc o'smaydi.
final class ContractCreateBloc extends Bloc<ContractCreateEvent, ContractCreateState> {
  ContractCreateBloc({
    required ContractCreateArgs args,
    required this._getDetails,
    required this._getPaymentDays,
    required this._getOccupations,
    required this._submit,
  }) : super(ContractCreateState.initial(args)) {
    on<ContractRequested>(_requested, transformer: droppable());
    on<ContractIdReceived>(_contractIdReceived);

    // Yozuvning o'zi shu ekranda tahrirlanadi va faqat yuborishda saqlanadi.
    on<TermChanged>(_termChanged);
    on<PaymentDaySelected>(_paymentDaySelected);
    on<BasisChanged>(_basisChanged);
    on<CarIncomeToggled>(_carToggled);
    on<OccupationSelected>(_occupationSelected);
    on<SubmitRequested>(_submitRequested, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetContractDetailsUsecase _getDetails;
  final GetPaymentDaysUsecase _getPaymentDays;
  final GetOccupationsUsecase _getOccupations;
  final SubmitContractUsecase _submit;

  /// Skoringga birinchi yuborishda `POST`, keyingilarida `PUT`.
  ///
  /// Mezon — marshrut argumenti emas, shartnoma statusi: qoralama status 1 da
  /// turadi va aynan shu holatda `POST` kutiladi.
  static const int draftStatus = 1;

  Future<void> _requested(ContractRequested event, Emitter<ContractCreateState> emit) async {
    emit(state.copyWith(isLoading: true, clearFailure: true));

    // Kasb ro'yxati shartnomadan mustaqil — qoralama yo'q bo'lsa ham kerak.
    final Result<OccupationCatalog> catalog = await _getOccupations(const NoParams());
    if (emit.isDone) return;

    switch (catalog) {
      case Ok(: final OccupationCatalog value):
        emit(state.copyWith(form: state.form.copyWith(catalog: value)));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
        return;
    }

    final int? id = state.contractId;
    if (id == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }

    final Result<ContractDetails> details = await _getDetails(id);
    if (emit.isDone) return;

    final ContractDetails loaded;

    switch (details) {
      case Ok(: final ContractDetails value):
        loaded = value;
        emit(
          state.copyWith(
            details: value,
            form: state.form.copyWith(
              termMonths: value.termMonths == 0 ? ContractForm.defaultTerm : value.termMonths,
              basis: IncomeBasis.of(isFormal: value.isFormal),
              hasCarIncome: value.hasCarIncome,
            ),
          ),
        );
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
        return;
    }

    final Result<List<int>> days = await _getPaymentDays(id);
    if (emit.isDone) return;

    switch (days) {
      case Ok(: final List<int> value):
        emit(
          state.copyWith(
            isLoading: false,
            form: state.form.withPaymentDays(value, preferredDay: loaded.paymentDay),
          ),
        );
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Tovarlar ekrani qoralama yaratdi — endi qolgan bosqichlar ochiladi.
  void _contractIdReceived(ContractIdReceived event, Emitter<ContractCreateState> emit) {
    if (state.contractId == event.contractId) return;

    emit(state.copyWith(contractId: event.contractId));
  }

  void _termChanged(TermChanged event, Emitter<ContractCreateState> emit) =>
      emit(state.copyWith(form: state.form.withTerm(event.value)));

  void _paymentDaySelected(PaymentDaySelected event, Emitter<ContractCreateState> emit) => emit(
    state.copyWith(form: state.form.copyWith(paymentDayIndex: event.index), issue: ContractFormIssue.none),
  );

  /// Karta biriktirilgan bo'lsa daromad asosi o'zgarmaydi: karta aylanmasi
  /// rasmiy daromadning dalili.
  void _basisChanged(BasisChanged event, Emitter<ContractCreateState> emit) {
    if (state.hasCard) return;

    emit(state.copyWith(form: state.form.copyWith(basis: event.basis), issue: ContractFormIssue.none));
  }

  void _carToggled(CarIncomeToggled event, Emitter<ContractCreateState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(hasCarIncome: !state.form.hasCarIncome)));

  void _occupationSelected(OccupationSelected event, Emitter<ContractCreateState> emit) => emit(
    state.copyWith(form: state.form.copyWith(occupation: event.occupation), issue: ContractFormIssue.none),
  );

  Future<void> _submitRequested(SubmitRequested event, Emitter<ContractCreateState> emit) async {
    if (state.isSubmitted || state.isSubmitting || state.isLoading) return;

    final int? contractId = state.contractId;
    final ContractFormIssue issue = state.currentIssue;

    if (issue != ContractFormIssue.none || contractId == null) {
      emit(state.copyWith(issue: issue == ContractFormIssue.none ? ContractFormIssue.noProducts : issue));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearFailure: true));

    final Result<void> result = await _submit(
      SubmitContractParams(
        contractId: contractId,
        termMonths: state.form.termMonths,
        paymentDay: state.form.paymentDay,
        isFormal: state.form.basis.isFormal,
        hasCarIncome: state.form.hasCarIncome,
        // Kasb turi server so'ragan holatdagina yuboriladi.
        occupationTypeId: state.form.isOccupationNeeded(hasCard: state.hasCard)
            ? state.form.occupation.id
            : 0,
        isEdit: (state.details?.statusCode ?? draftStatus) != draftStatus,
      ),
    );
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        emit(state.copyWith(isSubmitting: false, isSubmitted: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isSubmitting: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<ContractCreateState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _retried(Retried event, Emitter<ContractCreateState> emit) async {
    emit(state.copyWith(clearFailure: true));
    add(const ContractRequested());
  }
}
