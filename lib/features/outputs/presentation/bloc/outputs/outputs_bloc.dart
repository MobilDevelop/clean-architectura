import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/outputs_usecases.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/release_usecases.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'outputs_event.dart';
part 'outputs_state.dart';

/// Qaysi amal yiqildi. «Qayta urinish» aynan shuni takrorlaydi.
enum _Attempt { list, products, productReturn }

/// Chiqim tovarlar: chiqimga tayyor shartnomalar va ularning tovarlari.
final class OutputsBloc extends Bloc<OutputsEvent, OutputsState> {
  OutputsBloc({
    required this._getContracts,
    required this._getProducts,
    required this._returnProducts,
    required this._changes,
  }) : super(const OutputsState.initial()) {
    on<OutputsRequested>(_requested, transformer: restartable());
    on<NextPageRequested>(_nextPage, transformer: droppable());
    on<DateSelected>(_dateSelected);
    on<DateCleared>(_dateCleared);
    on<ContractToggled>(_toggled, transformer: restartable());
    on<ProductToggled>(_productToggled);
    // `droppable`: qaytarish qaytarib bo'lmaydigan amal, ikki marta bosish
    // ikkita so'rov yubormasligi kerak.
    on<ReturnRequested>(_returnRequested, transformer: droppable());
    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried);
  }

  final GetOutputContractsUsecase _getContracts;
  final GetOutputProductsUsecase _getProducts;
  final ReturnProductsUsecase _returnProducts;

  /// Qaytarish shartnoma holatini o'zgartiradi — shartnomalar ro'yxati
  /// eskiradi.
  final ContractChanges _changes;

  _Attempt _attempt = _Attempt.list;
  int _lastProductsId = 0;

  /// Birinchi sahifa. Ochiq qator va o'qilgan tovarlar tozalanadi: ro'yxat
  /// yangilangach ular boshqa shartnomalarga tegishli bo'lishi mumkin.
  Future<void> _requested(OutputsRequested event, Emitter<OutputsState> emit) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearFailure: true,
        query: state.query.copyWith(page: 1),
        openId: 0,
        products: const <int, List<OutputProduct>>{},
        selected: const <int>{},
      ),
    );

    final Result<OutputsPageResult> result = await _getContracts(state.query);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final OutputsPageResult value):
        emit(
          state.copyWith(
            isLoading: false,
            hasLoaded: true,
            contracts: value.items,
            isLast: value.isLast,
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.list;
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Keyingi sahifa. Oxirgi sahifadan keyin so'rov yuborilmaydi.
  Future<void> _nextPage(NextPageRequested event, Emitter<OutputsState> emit) async {
    if (state.isLast || state.isLoading || state.isPageLoading || state.contracts.isEmpty) return;

    final OutputsQuery next = state.query.copyWith(page: state.query.page + 1);

    emit(state.copyWith(isPageLoading: true, clearFailure: true));

    final Result<OutputsPageResult> result = await _getContracts(next);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final OutputsPageResult value):
        emit(
          state.copyWith(
            isPageLoading: false,
            // Sahifa raqami faqat muvaffaqiyatdan keyin oshadi: aks holda
            // yiqilgan so'rovdan keyin bitta sahifa butunlay tushib qolardi.
            query: next,
            contracts: <OutputContract>[...state.contracts, ...value.items],
            isLast: value.isLast,
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.list;
        emit(state.copyWith(isPageLoading: false, failure: failure));
    }
  }

  void _dateSelected(DateSelected event, Emitter<OutputsState> emit) {
    emit(state.copyWith(query: state.query.copyWith(date: event.date, page: 1)));
    add(const OutputsRequested());
  }

  void _dateCleared(DateCleared event, Emitter<OutputsState> emit) {
    emit(state.copyWith(query: state.query.copyWith(clearDate: true, page: 1)));
    add(const OutputsRequested());
  }

  /// Qatorni ochadi va tovarlarni bir marta o'qiydi.
  Future<void> _toggled(ContractToggled event, Emitter<OutputsState> emit) async {
    if (state.openId == event.contractId) {
      emit(state.copyWith(openId: 0, isProductsLoading: false, selected: const <int>{}));
      return;
    }

    // Belgilar ochiq shartnomaga tegishli: qator almashganda ular qolsa,
    // boshqa shartnomaning tovarlari qaytarilib ketardi.
    emit(state.copyWith(openId: event.contractId, selected: const <int>{}, clearFailure: true));

    // Bir marta o'qilgan tovarlar qayta so'ralmaydi: ular chiqim berilgunicha
    // o'zgarmaydi.
    if (state.products.containsKey(event.contractId)) return;

    _lastProductsId = event.contractId;
    emit(state.copyWith(isProductsLoading: true));

    final Result<List<OutputProduct>> result = await _getProducts(event.contractId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<OutputProduct> value):
        emit(
          state.copyWith(
            isProductsLoading: false,
            products: <int, List<OutputProduct>>{...state.products, event.contractId: value},
          ),
        );
      case Err(: final Failure failure):
        _attempt = _Attempt.products;
        // Qator yopiladi: ochiq turgan bo'sh qator "tovar yo'q" degan
        // ma'noni berardi (5.8).
        emit(state.copyWith(isProductsLoading: false, openId: 0, failure: failure));
    }
  }

  void _productToggled(ProductToggled event, Emitter<OutputsState> emit) {
    final Set<int> next = Set<int>.from(state.selected);

    if (!next.remove(event.productId)) next.add(event.productId);

    emit(state.copyWith(selected: next));
  }

  /// Belgilangan tovarlarni qaytaradi va ro'yxatni boshidan o'qiydi.
  ///
  /// Belgilar muvaffaqiyatdan keyin tozalanadi: yiqilganda ular joyida qolsa
  /// «Qayta urinish» xodimdan tanlovni qaytadan so'ramaydi.
  Future<void> _returnRequested(ReturnRequested event, Emitter<OutputsState> emit) async {
    if (state.openId == 0 || state.isReturning) return;

    final ProductReturnParams params = ProductReturnParams(
      contractId: state.openId,
      productIds: state.selected.toList(),
    );

    emit(state.copyWith(isReturning: true, isReturned: false, clearFailure: true));

    final Result<void> result = await _returnProducts(params);
    if (emit.isDone) return;

    switch (result) {
      case Ok():
        _changes.mark(ContractChange.updated);
        emit(state.copyWith(isReturning: false, isReturned: true, selected: const <int>{}));
        add(const OutputsRequested());
      case Err(: final Failure failure):
        _attempt = _Attempt.productReturn;
        emit(state.copyWith(isReturning: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<OutputsState> emit) =>
      emit(state.copyWith(clearFailure: true));

  void _retried(Retried event, Emitter<OutputsState> emit) {
    emit(state.copyWith(clearFailure: true));

    switch (_attempt) {
      case _Attempt.list:
        add(const OutputsRequested());
      case _Attempt.products:
        if (_lastProductsId != 0) add(ContractToggled(_lastProductsId));
      case _Attempt.productReturn:
        add(const ReturnRequested());
    }
  }
}
