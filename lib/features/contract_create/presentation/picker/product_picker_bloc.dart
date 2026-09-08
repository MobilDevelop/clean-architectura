import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/catalog_usecases.dart';
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
  }) : super(const ProductPickerState.initial()) {
    on<SupplierSelected>(_supplierSelected);
    on<CategorySelected>(_categorySelected);
    on<BrandSelected>(_brandSelected);
    on<VariantSelected>(_variantSelected);
    on<PriceChanged>(_priceChanged);
    on<CountChanged>(_countChanged);
    on<ImeiAdded>(_imeiAdded);
    on<ImeiRemoved>(_imeiRemoved);
    on<SubmitRequested>(_submitRequested);
  }

  final GetSuppliersUsecase _suppliers;
  final GetCategoriesUsecase _categories;
  final GetBrandsUsecase _brands;
  final GetVariantsUsecase _variants;

  // Ma'lumotnoma yuklovchilari. Ular holatga tegmaydi — oyna ularni to'g'ridan
  // to'g'ri chaqiradi, sahifa esa `getIt` ni ko'rmaydi (8.2).
  Future<Result<Paged<CatalogItem>>> loadSuppliers(CatalogQuery query) => _suppliers(query);

  Future<Result<Paged<ProductCategory>>> loadCategories(CatalogQuery query) =>
      _categories(CategoryQuery(query: query, supplierId: state.draft.supplier?.id ?? 0));

  Future<Result<Paged<CatalogItem>>> loadBrands(CatalogQuery query) =>
      _brands(BrandQuery(query: query, categoryId: state.draft.category?.id ?? 0));

  Future<Result<Paged<CatalogItem>>> loadVariants(CatalogQuery query) => _variants(
    VariantQuery(
      query: query,
      categoryId: state.draft.category?.id ?? 0,
      brandId: state.draft.brand?.id ?? 0,
    ),
  );

  // Har o'zgarishda xato tozalanadi: foydalanuvchi tuzata boshladi.
  void _supplierSelected(SupplierSelected event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.withSupplier(event.value), issue: ProductDraftIssue.none));

  void _categorySelected(CategorySelected event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.withCategory(event.value), issue: ProductDraftIssue.none));

  void _brandSelected(BrandSelected event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.withBrand(event.value), issue: ProductDraftIssue.none));

  void _variantSelected(VariantSelected event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.copyWith(variant: event.value), issue: ProductDraftIssue.none));

  void _priceChanged(PriceChanged event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.copyWith(price: event.value), issue: ProductDraftIssue.none));

  void _countChanged(CountChanged event, Emitter<ProductPickerState> emit) =>
      emit(state.copyWith(draft: state.draft.copyWith(count: event.value), issue: ProductDraftIssue.none));

  /// Bir xil raqam ikki marta qo'shilmaydi — har nusxa alohida raqamlanadi.
  void _imeiAdded(ImeiAdded event, Emitter<ProductPickerState> emit) {
    final String value = event.value.trim();
    if (value.isEmpty || state.draft.imeis.contains(value)) return;

    emit(
      state.copyWith(
        draft: state.draft.copyWith(imeis: <String>[...state.draft.imeis, value]),
        issue: ProductDraftIssue.none,
      ),
    );
  }

  void _imeiRemoved(ImeiRemoved event, Emitter<ProductPickerState> emit) => emit(
    state.copyWith(
      draft: state.draft.copyWith(imeis: state.draft.imeis.where((String e) => e != event.value).toList()),
      issue: ProductDraftIssue.none,
    ),
  );

  void _submitRequested(SubmitRequested event, Emitter<ProductPickerState> emit) {
    final ProductDraftIssue issue = state.draft.issue;

    emit(state.copyWith(issue: issue, isReady: issue == ProductDraftIssue.none));
  }
}
