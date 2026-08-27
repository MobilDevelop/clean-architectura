import 'package:equatable/equatable.dart';

sealed class CustomersEvent extends Equatable {
  const CustomersEvent();

  @override
  List<Object> get props => [];
}

final class ShowSearch extends CustomersEvent{
  const ShowSearch();
}

/// Har harfda — matn o'zgardi
final class SearchQueryChanged extends CustomersEvent {
  const SearchQueryChanged(this.query);
  final String query;
}

/// Enter bosildi
final class SearchSubmitted extends CustomersEvent {
  const SearchSubmitted();
}

final class FailureHandled extends CustomersEvent {
  const FailureHandled();
}
