part of 'product_picker_bloc.dart';

sealed class ProductPickerEvent extends Equatable {
  const ProductPickerEvent();

  @override
  List<Object> get props => [];
}

final class SupplierSelected extends ProductPickerEvent {
  const SupplierSelected(this.value);

  final CatalogItem value;

  @override
  List<Object> get props => [value];
}

final class CategorySelected extends ProductPickerEvent {
  const CategorySelected(this.value);

  final ProductCategory value;

  @override
  List<Object> get props => [value];
}

final class BrandSelected extends ProductPickerEvent {
  const BrandSelected(this.value);

  final CatalogItem value;

  @override
  List<Object> get props => [value];
}

final class VariantSelected extends ProductPickerEvent {
  const VariantSelected(this.value);

  final CatalogItem value;

  @override
  List<Object> get props => [value];
}

final class PriceChanged extends ProductPickerEvent {
  const PriceChanged(this.value);

  final int value;

  @override
  List<Object> get props => [value];
}

final class CountChanged extends ProductPickerEvent {
  const CountChanged(this.value);

  final int value;

  @override
  List<Object> get props => [value];
}

final class SubmitRequested extends ProductPickerEvent {
  const SubmitRequested();
}

/// Sahifa suratni oldi. Kamera ochish — UI ta'siri, u bloc ichida emas (6.2).
final class ImeiScanned extends ProductPickerEvent {
  const ImeiScanned(this.image);

  final File image;

  @override
  List<Object> get props => [image.path];
}

/// Kamera ochilmadi — sahifa sababini aytadi.
final class CameraRefused extends ProductPickerEvent {
  const CameraRefused(this.issue);

  final CameraIssue issue;

  @override
  List<Object> get props => [issue];
}

/// Aloqa xatosidan keyin oxirgi suratni qayta yuborish.
final class ScanRetried extends ProductPickerEvent {
  const ScanRetried();
}

final class FailureHandled extends ProductPickerEvent {
  const FailureHandled();
}
