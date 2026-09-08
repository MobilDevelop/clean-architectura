import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/delete_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/add_product_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/contract_write_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'contract_products_event.dart';
part 'contract_products_state.dart';

/// Shartnoma tovarlari — qo'shish, tahrirlash, o'chirish.
///
/// Qoralamani yaratadigan yagona ekran shu: qoralama birinchi tovar
/// qo'shilganda paydo bo'ladi, ekran ochilganda emas. Aks holda tashlab
/// ketilgan har bir urinish shartnomalar ro'yxatida axlat qator qoldirardi.
final class ContractProductsBloc extends Bloc<ContractProductsEvent, ContractProductsState>
    with ContractWriteMixin<ContractProductsEvent, ContractProductsState> {
  ContractProductsBloc({
    required ContractCreateArgs args,
    required this._getDetails,
    required this._createDraft,
    required this._addProduct,
    required this._updateProduct,
    required this._deleteProduct,
  }) : super(ContractProductsState.initial(args)) {
    on<ProductsRequested>(_requested, transformer: droppable());

    // Yozuvlar navbat bilan: ikkitasi bir vaqtda ketsa, ro'yxat qaysi
    // javobdan yig'ilgani aniqlanmay qoladi.
    on<ProductAdded>(_added, transformer: sequential());
    on<ProductSaved>(_saved, transformer: sequential());
    on<ProductRemoved>(_removed, transformer: sequential());

    on<FailureHandled>(_failureHandled);
    on<Retried>(_retried, transformer: droppable());
  }

  final GetContractDetailsUsecase _getDetails;
  final CreateDraftUsecase _createDraft;
  final AddProductUsecase _addProduct;
  final UpdateProductUsecase _updateProduct;
  final DeleteProductUsecase _deleteProduct;

  Future<void> _requested(ProductsRequested event, Emitter<ContractProductsState> emit) async {
    final int? id = state.contractId;

    // Qoralama hali yo'q — yuklanadigan narsa ham yo'q.
    if (id == null) return;

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<ContractDetails> result = await _getDetails(id);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final ContractDetails value):
        emit(state.copyWith(isLoading: false, products: value.products));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  /// Qoralamani kerak bo'lganda yaratadi.
  ///
  /// Xato `Err` bo'lib qaytadi — chaqiruvchi uni tovar qo'shish xatosidan
  /// ajratmaydi va "Qayta urinish" ikkalasida ham bir xil ishlaydi.
  Future<Result<int>> _ensureDraft(Emitter<ContractProductsState> emit) async {
    final int? existing = state.contractId;
    if (existing != null) return Ok<int>(existing);

    final Result<int> result = await _createDraft(state.args.clientId);
    if (emit.isDone) return result;

    // Revizya oshirilmaydi: qoralamaning o'zida hali o'qiydigan narsa yo'q.
    // `contractId` ning paydo bo'lishi alohida signal.
    if (result case Ok(: final int value)) emit(state.copyWith(contractId: value));

    return result;
  }

  Future<void> _added(ProductAdded event, Emitter<ContractProductsState> emit) => write<int>(
    event: event,
    emit: emit,
    busy: state.copyWith(write: ProductWrite.adding, clearFailure: true, clearBusyProduct: true),
    run: () async {
      final Result<int> draft = await _ensureDraft(emit);
      final int contractId;

      switch (draft) {
        case Ok(: final int value):
          contractId = value;
        case Err(: final Failure failure):
          return Err<int>(failure);
      }

      final ProductDraft product = event.draft;

      return _addProduct(
        AddProductParams(
          contractId: contractId,
          supplierId: product.supplier?.id ?? 0,
          categoryId: product.category?.id ?? 0,
          brandId: product.brand?.id ?? 0,
          variantId: product.variant?.id ?? 0,
          price: product.price,
          count: product.effectiveCount,
          imeis: product.imeis,
        ),
      );
    },
    // Qator faqat server id bergandan keyin ro'yxatga qo'shiladi.
    onOk: (int id) => state.copyWith(
      write: ProductWrite.none,
      revision: state.revision + 1,
      products: <ContractProduct>[...state.products, event.draft.toProduct(id)],
    ),
    onFailure: (Failure failure) => state.copyWith(write: ProductWrite.none, failure: failure),
  );

  Future<void> _saved(ProductSaved event, Emitter<ContractProductsState> emit) async {
    final ContractProduct? row = _rowById(event.productId);
    if (row == null) return;

    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(write: ProductWrite.saving, busyProductId: event.productId, clearFailure: true),
      run: () => _updateProduct(
        UpdateProductParams(
          productId: event.productId,
          supplierId: row.supplier.id,
          price: event.price,
          count: event.count,
        ),
      ),
      onOk: (_) => state.copyWith(
        write: ProductWrite.none,
        clearBusyProduct: true,
        revision: state.revision + 1,
        products: state.products
            .map(
              (ContractProduct e) =>
                  e.id == event.productId ? e.withPriceAndCount(price: event.price, count: event.count) : e,
            )
            .toList(),
      ),
      onFailure: (Failure failure) => state.copyWith(write: ProductWrite.none, failure: failure),
    );
  }

  Future<void> _removed(ProductRemoved event, Emitter<ContractProductsState> emit) async {
    final int? contractId = state.contractId;
    if (contractId == null) return;

    await write<void>(
      event: event,
      emit: emit,
      busy: state.copyWith(write: ProductWrite.removing, busyProductId: event.productId, clearFailure: true),
      run: () => _deleteProduct(DeleteProductParams(productId: event.productId, contractId: contractId)),
      // Qator faqat server tasdiqlagandan keyin olib tashlanadi.
      onOk: (_) => state.copyWith(
        write: ProductWrite.none,
        clearBusyProduct: true,
        revision: state.revision + 1,
        products: state.products.where((ContractProduct e) => e.id != event.productId).toList(),
      ),
      onFailure: (Failure failure) => state.copyWith(write: ProductWrite.none, failure: failure),
    );
  }

  ContractProduct? _rowById(int id) {
    for (final ContractProduct item in state.products) {
      if (item.id == id) return item;
    }

    return null;
  }

  void _failureHandled(FailureHandled event, Emitter<ContractProductsState> emit) =>
      emit(state.copyWith(clearFailure: true, clearBusyProduct: true));

  Future<void> _retried(Retried event, Emitter<ContractProductsState> emit) async {
    emit(state.copyWith(clearFailure: true, clearBusyProduct: true));

    // Yozuv xatosi bo'lmasa — xato yuklashda bo'lgan.
    if (!retryLastWrite()) add(const ProductsRequested());
  }
}
