import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/add_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/add_product_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/catalog_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/picker/camera_issue.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'product_picker_event.dart';
part 'product_picker_state.dart';

/// Tovar tanlash formasi.
///
/// Hech qanday so'rov yubormaydi: natijani sahifa qaytaradi, yozuvni shartnoma
/// ekranining bloci bajaradi. Shu sababli u sof va testlanadi.
final class ProductPickerBloc extends Bloc<ProductPickerEvent, ProductPickerState> {
  ProductPickerBloc({
    required this._suppliers,
    required this._categories,
    required this._brands,
    required this._variants,
    required this._scanImei,
  }) : super(const ProductPickerState.initial()) {
    on<SupplierSelected>(_supplierSelected);
    on<CategorySelected>(_categorySelected);
    on<BrandSelected>(_brandSelected);
    on<VariantSelected>(_variantSelected);
    on<PriceChanged>(_priceChanged);
    on<CountChanged>(_countChanged);
    // `restartable`: yangi surat eskisining o'rnini egallaydi. `droppable`
    // bo'lganda ikkinchi surat jimgina tashlanardi — tovar almashtirilgach
    // tugma qaytadan ochilgani uchun bu oson yuz berardi.
    on<ImeiScanned>(_imeiScanned, transformer: restartable());
    on<ScanRetried>(_scanRetried);
    on<CameraRefused>(_cameraRefused);
    on<FailureHandled>(_failureHandled);
    on<SubmitRequested>(_submitRequested);
  }

  final GetSuppliersUsecase _suppliers;
  final GetCategoriesUsecase _categories;
  final GetBrandsUsecase _brands;
  final GetVariantsUsecase _variants;
  final ScanImeiUsecase _scanImei;

  /// Oxirgi surat — aloqa uzilganda foydalanuvchi qaytadan suratga olmasin.
  File? _lastShot;

  // Ma'lumotnoma yuklovchilari. Ular holatga tegmaydi — oyna ularni to'g'ridan
  // to'g'ri chaqiradi, sahifa esa `getIt` ni ko'rmaydi (8.2).
  Future<Result<Paged<CatalogItem>>> loadSuppliers(CatalogQuery query) => _suppliers(query);

  Future<Result<Paged<ProductCategory>>> loadCategories(CatalogQuery query) => _categories(CategoryQuery(query: query, supplierId: state.draft.supplier?.id ?? 0));

  Future<Result<Paged<CatalogItem>>> loadBrands(CatalogQuery query) => _brands(BrandQuery(query: query, categoryId: state.draft.category?.id ?? 0));

  Future<Result<Paged<CatalogItem>>> loadVariants(CatalogQuery query) => _variants(VariantQuery(query: query,categoryId: state.draft.category?.id ?? 0,brandId: state.draft.brand?.id ?? 0));

  // Yuqoridagi tanlov o'zgarsa tovar ham bekor bo'ladi (`with*` uni
  // uzatmaydi), demak o'qilgan IMEI'lar ham, ularning xatosi ham eskiradi.
  void _supplierSelected(SupplierSelected event, Emitter<ProductPickerState> emit) => _cascade(emit, state.draft.withSupplier(event.value));

  void _categorySelected(CategorySelected event, Emitter<ProductPickerState> emit) => _cascade(emit, state.draft.withCategory(event.value));

  void _brandSelected(BrandSelected event, Emitter<ProductPickerState> emit) => _cascade(emit, state.draft.withBrand(event.value));

  void _variantSelected(VariantSelected event, Emitter<ProductPickerState> emit) => _cascade(emit, state.draft.withVariant(event.value));

  /// Tovarni bekor qiladigan har qanday tanlov: o'qish natijasi, oxirgi surat
  /// va xato birga tozalanadi. Aks holda ekranda amal qilmaydigan «Qayta
  /// urinish» tugmasi qolib ketardi — u oldingi qurilmaning suratini
  /// yuborardi.
  void _cascade(Emitter<ProductPickerState> emit, ProductDraft draft) {
    _lastShot = null;

    emit(state.copyWith(draft: draft,issue: ProductDraftIssue.none,isScanning: false,cameraIssue: CameraIssue.none,clearFailure: true));
  }

  void _priceChanged(PriceChanged event, Emitter<ProductPickerState> emit) => emit(state.copyWith(draft: state.draft.copyWith(price: event.value), issue: ProductDraftIssue.none));

  void _countChanged(CountChanged event, Emitter<ProductPickerState> emit) => emit(state.copyWith(draft: state.draft.copyWith(count: event.value), issue: ProductDraftIssue.none));

  /// Javob ro'yxatni **butunligicha almashtiradi**: server yorliqdagi
  /// qurilmaga tegishli barcha IMEI'larni qaytaradi, ya'ni bu to'liq ro'yxat.
  /// Shu sababli qo'shish emas, almashtirish — eski o'qish natijasi qolsa
  /// ikkita qurilmaning raqamlari aralashib ketardi.
  Future<void> _imeiScanned(ImeiScanned event, Emitter<ProductPickerState> emit) async {
    final int variantId = state.draft.variant?.id ?? 0;

    // Server IMEI'ni tovar turiga qarab o'qiydi. Tovar tanlanmagan bo'lsa
    // so'rov ma'nosiz — sabab «Tovar» maydoni tagida ko'rsatiladi (5.8).
    if (variantId == 0) {
      emit(state.copyWith(issue: ProductDraftIssue.variantMissing));
      return;
    }

    _lastShot = event.image;
    emit(state.copyWith(isScanning: true,issue: ProductDraftIssue.none,cameraIssue: CameraIssue.none,clearFailure: true));

    final Result<List<String>> result = await _scanImei(ScanImeiParams(variantId: variantId, image: event.image));
    if (emit.isDone) return;

    // Javob kelguncha foydalanuvchi boshqa tovarga o'tgan bo'lishi mumkin.
    // U holda bu raqamlar boshqa qurilmaniki — ular yangi tanlovga
    // yopishtirilmaydi va holat ham qaytarilmaydi (uni tanlov allaqachon
    // tozalagan).
    if ((state.draft.variant?.id ?? 0) != variantId) return;

    switch (result) {
      // `issue` ham tozalanadi: skan tugaguncha «Qo'shish» bosilgan bo'lsa,
      // maydon tagida «yorliqni suratga oling» qizil matni qolib ketardi —
      // ro'yxat to'lgan bo'lsa ham.
      case Ok(:final List<String> value): emit(state.copyWith(isScanning: false,issue: ProductDraftIssue.none,draft: state.draft.copyWith(imeis: value)));
      case Err(:final Failure failure): emit(state.copyWith(isScanning: false, failure: failure));
    }
  }

  /// Oxirgi suratni qayta yuboradi — foydalanuvchi ikkinchi marta suratga
  /// olmasin. Hodisa sifatida qo'shiladi: shunda u `ImeiScanned` bilan bir
  /// navbatda turadi va ikkalasi bir vaqtda ishlab ketmaydi.
  void _scanRetried(ScanRetried event, Emitter<ProductPickerState> emit) {
    final File? shot = _lastShot;
    if (shot == null) return;

    add(ImeiScanned(shot));
  }

  void _cameraRefused(CameraRefused event, Emitter<ProductPickerState> emit) => emit(state.copyWith(isScanning: false, cameraIssue: event.issue));

  void _failureHandled(FailureHandled event, Emitter<ProductPickerState> emit) => emit(state.copyWith(clearFailure: true));

  /// Skan tugamaguncha yuborilmaydi: aks holda ekran hali yo'ldagi ro'yxat
  /// o'rniga eskisini shartnomaga yozib yopilardi. Sabab ko'rinib turadi —
  /// tugmada aylanish belgisi, IMEI blokida esa «raqamlar o'qilyapti».
  void _submitRequested(SubmitRequested event, Emitter<ProductPickerState> emit) {
    if (state.isScanning) return;

    final ProductDraftIssue issue = state.draft.issue;

    emit(state.copyWith(issue: issue, isReady: issue == ProductDraftIssue.none));
  }
}
