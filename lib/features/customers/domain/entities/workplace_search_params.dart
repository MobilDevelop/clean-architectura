import 'package:equatable/equatable.dart';

/// Ish joyi tumanga bog'liq — qidiruv ikkalasini birga oladi.
final class WorkplaceSearchParams extends Equatable {
  const WorkplaceSearchParams({required this.regionId, required this.query});

  final int regionId;
  final String query;

  @override
  List<Object?> get props => [regionId, query];
}
