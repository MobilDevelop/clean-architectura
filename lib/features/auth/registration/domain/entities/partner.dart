import 'package:equatable/equatable.dart';

import 'organization.dart';

final class Partner extends Equatable {
  const Partner({required this.id, required this.title, required this.territoryId, required this.organizations});

  final int id;
  final String title;
  final int territoryId;
  final List<Organization> organizations;

  @override
  List<Object> get props => [id, title, territoryId, organizations];

}