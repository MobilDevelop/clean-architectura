import 'package:equatable/equatable.dart';

final class ContractsFilter extends Equatable {
  const ContractsFilter({this.date, this.page = 1, this.perPage = 40});

  final DateTime? date;
  final int page;
  final int perPage;

  ContractsFilter copyWith({DateTime? date, int? page, int? perPage, bool clearDate = false}) => ContractsFilter(
    date: clearDate ? null : (date ?? this.date),
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
  );

  @override
  List<Object> get props => [?date, page, perPage];
}
