part of 'catalog_bloc.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object> get props => [];
}

/// Qidiruv matni o'zgardi yoki ro'yxat birinchi marta ochildi.
final class CatalogSearched extends CatalogEvent {
  const CatalogSearched(this.query, {this.debounce = true});

  final String query;

  /// Birinchi yuklashda kutish kerak emas.
  final bool debounce;

  @override
  List<Object> get props => [query, debounce];
}

final class CatalogNextPage extends CatalogEvent {
  const CatalogNextPage();
}
