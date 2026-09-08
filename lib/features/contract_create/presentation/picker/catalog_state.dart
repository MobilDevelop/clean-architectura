part of 'catalog_bloc.dart';

final class CatalogState<T> extends Equatable {
  const CatalogState({
    required this.items,
    required this.search,
    required this.page,
    required this.isLoading,
    required this.isLast,
    this.failure,
  });

  const CatalogState.initial()
    : items = const <Never>[],
      search = '',
      page = 1,
      isLoading = false,
      isLast = false,
      failure = null;

  final List<T> items;
  final String search;

  /// Oxirgi muvaffaqiyatli olingan sahifa.
  final int page;

  final bool isLoading;
  final bool isLast;
  final Failure? failure;

  CatalogState<T> copyWith({
    List<T>? items,
    String? search,
    int? page,
    bool? isLoading,
    bool? isLast,
    Failure? failure,
    bool clearFailure = false,
  }) => CatalogState<T>(
    items: items ?? this.items,
    search: search ?? this.search,
    page: page ?? this.page,
    isLoading: isLoading ?? this.isLoading,
    isLast: isLast ?? this.isLast,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [items, search, page, isLoading, isLast, failure];
}
