import 'package:colloborator_v3/features/contracts/data/models/guarantor_info_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('to‘liq yozuv o‘qiladi', () {
    final entity = GuarantorInfoDto.fromJson(<String, dynamic>{
      'id': 33,
      'client_fio': 'KARIMOV ALI',
    }).toEntity();

    expect(entity.id, 33);
    expect(entity.name, 'KARIMOV ALI');
  });

  test('id siz yiqiladi', () {
    expect(
      () => GuarantorInfoDto.fromJson(<String, dynamic>{'client_fio': 'KARIMOV ALI'}),
      throwsFormatException,
    );
  });
}
