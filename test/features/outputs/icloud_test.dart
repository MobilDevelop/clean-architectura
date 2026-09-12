import 'package:colloborator_v3/features/outputs/data/models/icloud_requirement_dto.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:flutter_test/flutter_test.dart';

IcloudCredential _full() => const IcloudCredential(
  contractId: 7,
  contractProductId: 3,
  condition: 'Yangi',
  hasBox: true,
  imei: '123456789012345',
  imei2: '',
  serialNumber: 'SN1',
  login: 'a@icloud.com',
  password: 'parol',
  appleLogin: AppleIdOwner.own,
  applePassword: AppleIdOwner.personal,
  restrictionCode: '1234',
  phone: '998901234567',
);

void main() {
  group('talablar javobi', () {
    // `true` zaxira qiymati kalit yo'qolganda chiqimni ochib yuborardi —
    // tekshiruv jimgina o'chib qolardi (4.6).
    test('is_satisfied kelmasa talab bajarilmagan deb qaraladi', () {
      final IcloudRequirements value = IcloudRequirementsDto.fromJson(
        <String, dynamic>{'contract_id': 7},
      ).toEntity();

      expect(value.isSatisfied, isFalse);
      expect(value.devices, isEmpty);
    });

    test('qurilmalar o‘qiladi', () {
      final IcloudRequirements value = IcloudRequirementsDto.fromJson(<String, dynamic>{
        'contract_id': 7,
        'is_satisfied': true,
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'contract_product_id': 11,
            'product_variant_id': 22,
            'name': 'iPhone 15',
            'full_name': 'iPhone 15 128GB',
            'imei': '111111111111111',
            'imei2': '222222222222222',
            'missing': 0,
          },
        ],
      }).toEntity();

      expect(value.isSatisfied, isTrue);
      expect(value.devices.single.contractProductId, 11);
      expect(value.devices.single.productId, 22);
      expect(value.devices.single.isFilled, isTrue);
    });

    // `missing` kelmaganda `0` qo'yilsa, barcha qurilma «to'ldirilgan» bo'lib
    // ochilmay qolardi.
    test('missing kelmasa qurilma ochiq qoladi', () {
      final IcloudRequirements value = IcloudRequirementsDto.fromJson(<String, dynamic>{
        'items': <Map<String, dynamic>>[<String, dynamic>{'contract_product_id': 11}],
      }).toEntity();

      expect(value.devices.single.missing, isNull);
      expect(value.devices.single.isFilled, isFalse);
    });
  });

  group('forma tekshiruvi', () {
    test('to‘liq forma o‘tadi', () => expect(_full().issue, IcloudIssue.none));

    test('har bir maydon o‘z xatosini beradi', () {
      expect(_full().copyWith(condition: '  ').issue, IcloudIssue.conditionMissing);
      expect(
        IcloudCredential(
          contractId: 7,
          contractProductId: 3,
          condition: _full().condition,
        ).issue,
        IcloudIssue.boxMissing,
      );
      expect(_full().copyWith(imei: '12345').issue, IcloudIssue.imeiShort);
      expect(_full().copyWith(serialNumber: '').issue, IcloudIssue.serialMissing);
      expect(_full().copyWith(login: '').issue, IcloudIssue.loginMissing);
      expect(_full().copyWith(password: '').issue, IcloudIssue.passwordMissing);
      expect(_full().copyWith(restrictionCode: '12').issue, IcloudIssue.restrictionShort);
      expect(_full().copyWith(phone: '99890').issue, IcloudIssue.phoneShort);
    });

    // IMEI2 bitta SIM'li qurilmada umuman bo'lmaydi — uni majburiy qilish
    // shunday qurilmani saqlab bo'lmaydigan qilardi.
    test('ikkinchi IMEI majburiy emas', () => expect(_full().copyWith(imei2: '').issue, IcloudIssue.none));
  });

  group('serverga yuboriladigan tana', () {
    test('kalitlar va qiymatlar', () {
      final Map<String, dynamic> body = IcloudCredentialBody.of(_full());

      expect(body['contract_id'], 7);
      expect(body['contract_product_id'], 3);
      expect(body['product_status'], 'Yangi');
      expect(body['has_box'], isTrue);
      expect(body['serial_number'], 'SN1');
      expect(body['restriction_code'], '1234');
      expect(body['icloud_phone'], '998901234567');
    });

    // Server aynan shu ikki qatorni kutadi — tarjima qilinsa yozuv boshqacha
    // ketardi.
    test('Apple ID egasi serverning yozuvi bilan ketadi', () {
      final Map<String, dynamic> body = IcloudCredentialBody.of(_full());

      expect(body['apple_id_login'], 'OZINIKI');
      expect(body['apple_id_password'], 'Личный');
    });
  });
}
