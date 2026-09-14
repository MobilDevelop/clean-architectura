import 'package:colloborator_v3/features/contract_create/data/models/special_tariff_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpecialTariffDto', () {
    test('to‘liq yozuv o‘qiladi', () {
      final entity = SpecialTariffDto.fromJson(<String, dynamic>{
        'id': 4,
        'name': 'Yozgi aksiya',
        'front_margin': 5,
        'prepayment_percent': 10,
        'back_margin': <String, dynamic>{
          'first_quarter': 1,
          'second_quarter': 2,
          'third_quarter': 3,
          'fourth_quarter': 4,
        },
      }).toEntity();

      expect(entity.id, 4);
      expect(entity.quarters, [1, 2, 3, 4]);
    });

    test('id siz yiqiladi', () {
      expect(() => SpecialTariffDto.fromJson(<String, dynamic>{'name': 'Yozgi'}).toEntity(), throwsFormatException);
    });
  });

  group('AppliedTariffDto', () {
    test('bo‘sh obyekt "biriktirilmagan" bo‘ladi', () {
      final entity = AppliedTariffDto.fromJson(const <String, dynamic>{}).toEntity();

      expect(entity.isEmpty, isTrue);
    });

    test('to‘liq yozuv o‘qiladi', () {
      final entity = AppliedTariffDto.fromJson(<String, dynamic>{
        'id': 4,
        'name': 'Yozgi aksiya',
        'active': true,
      }).toEntity();

      expect(entity.isEmpty, isFalse);
      expect(entity.name, 'Yozgi aksiya');
    });
  });
}
