import 'package:colloborator_v3/features/customers/data/models/workplace_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ichma-ich kategoriya (mijoz obyekti)', () {
    final WorkplaceInfo workplace = WorkplaceInfoDto.fromJson(<String, dynamic>{
      'id': 7,
      'name': 'Ishonch',
      'category': <String, dynamic>{'id': 3, 'name': 'Savdo'},
    }).toEntity();

    expect(workplace.category.id, 3);
    expect(workplace.category.name, 'Savdo');
  });

  test('tekis kategoriya (qidiruv natijasi)', () {
    final WorkplaceInfo workplace = WorkplaceInfoDto.fromJson(<String, dynamic>{
      'id': 7,
      'name': 'Ishonch',
      'category_id': 3,
      'category_name': 'Savdo',
    }).toEntity();

    expect(workplace.category.id, 3);
    expect(workplace.category.name, 'Savdo');
  });

  test('kategoriyasiz ish joyi tushib qolmaydi', () {
    final WorkplaceInfo workplace = WorkplaceInfoDto.fromJson(<String, dynamic>{
      'id': 7,
      'name': 'Ishonch',
    }).toEntity();

    expect(workplace.id, 7);
    expect(workplace.category.name, '');
  });

  test('bo‘sh obyekt tanlanmagan holatni bildiradi', () {
    expect(WorkplaceInfoDto.fromJson(const <String, dynamic>{}).toEntity().id, 0);
  });
}
