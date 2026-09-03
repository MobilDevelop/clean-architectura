import 'package:equatable/equatable.dart';

final class WorkplaceInfo extends Equatable{

 const WorkplaceInfo({required this.id,required this.name,required this.category});

  final int id;
  final String name;
  final WorkplaceCategory category;

  @override
  List<Object?> get props => [id,name,category];
}

final class WorkplaceCategory extends Equatable{
  const WorkplaceCategory({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id,name];
}