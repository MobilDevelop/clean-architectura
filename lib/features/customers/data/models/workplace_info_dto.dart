
import 'package:colloborator_v3/features/customers/domain/entities/workpalce_info.dart';

final class WorkplaceInfoDto{

 const WorkplaceInfoDto({required this.id,required this.name,required this.workplaceCategoryDto});

  factory WorkplaceInfoDto.fromJson(Map<String,dynamic> json)=>WorkplaceInfoDto(
    id: json['id'] as int,
    name: json['name'] as String,
    workplaceCategoryDto: WorkplaceCategoryDto.fromJson(json['category'] as Map<String,dynamic>)
  );

  final int id;
  final String name;
  final WorkplaceCategoryDto workplaceCategoryDto;

  WorkplaceInfo toEntity()=>WorkplaceInfo(id: id, name: name, category: workplaceCategoryDto.toEntity());

}

final class WorkplaceCategoryDto{

  const WorkplaceCategoryDto({required this.id, required this.name});

  factory WorkplaceCategoryDto.fromJson(Map<String,dynamic> json)=>WorkplaceCategoryDto(
    id: json['id'] as int,
    name: json['name'] as String,
  );


  final int id;
  final String name;

  WorkplaceCategory toEntity()=>WorkplaceCategory(id: id, name: name);

}