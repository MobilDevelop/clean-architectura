part of 'contract_products_bloc.dart';

sealed class ContractProductsEvent extends Equatable {
  const ContractProductsEvent();

  @override
  List<Object> get props => [];
}

final class ProductsRequested extends ContractProductsEvent {
  const ProductsRequested();
}

final class ProductAdded extends ContractProductsEvent {
  const ProductAdded(this.draft);

  final ProductDraft draft;

  @override
  List<Object> get props => [draft];
}

final class ProductSaved extends ContractProductsEvent {
  const ProductSaved({required this.productId, required this.price, required this.count});

  final int productId;
  final int price;
  final int count;

  @override
  List<Object> get props => [productId, price, count];
}

final class ProductRemoved extends ContractProductsEvent {
  const ProductRemoved(this.productId);

  final int productId;

  @override
  List<Object> get props => [productId];
}

final class FailureHandled extends ContractProductsEvent {
  const FailureHandled();
}

/// Muvaffaqiyatsiz amalni takrorlash.
final class Retried extends ContractProductsEvent {
  const Retried();
}
