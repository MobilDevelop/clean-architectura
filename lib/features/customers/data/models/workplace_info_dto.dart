
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';

final class WorkplaceInfoDto{

 const WorkplaceInfoDto({required this.id,required this.name,required this.workplaceCategoryDto});

  /// Ish joyi tanlanmagan mijozda bo'sh obyekt keladi — `id: 0` shu holat.
  ///
  /// Kategoriya ikki xil shaklda keladi: mijoz obyektida ichma-ich
  /// (`category: {id, name}`), qidiruv natijasida esa tekis
  /// (`category_id`, `category_name`). Ikkalasi ham qo'llab-quvvatlanadi.
  factory WorkplaceInfoDto.fromJson(Map<String,dynamic> json)=>WorkplaceInfoDto(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
    workplaceCategoryDto: WorkplaceCategoryDto.fromJson(
      json['category'] as Map<String,dynamic>? ??
          <String,dynamic>{'id': json['category_id'], 'name': json['category_name']},
    ),
  );

  final int id;
  final String name;
  final WorkplaceCategoryDto workplaceCategoryDto;

  WorkplaceInfo toEntity()=>WorkplaceInfo(id: id, name: name, category: workplaceCategoryDto.toEntity());

}

final class WorkplaceCategoryDto{

  const WorkplaceCategoryDto({required this.id, required this.name});

  factory WorkplaceCategoryDto.fromJson(Map<String,dynamic> json)=>WorkplaceCategoryDto(
    id: json['id'] as int? ?? 0,
    name: json['name'] as String? ?? '',
  );


  final int id;
  final String name;

  WorkplaceCategory toEntity()=>WorkplaceCategory(id: id, name: name);

}