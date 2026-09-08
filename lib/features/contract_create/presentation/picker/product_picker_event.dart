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

final class ImeiAdded extends ProductPickerEvent {
  const ImeiAdded(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class ImeiRemoved extends ProductPickerEvent {
  const ImeiRemoved(this.value);

  final String value;

  @override
  List<Object> get props => [value];
}

final class SubmitRequested extends ProductPickerEvent {
  const SubmitRequested();
}
