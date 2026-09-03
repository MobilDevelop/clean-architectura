import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/domain/entities/relative_kind.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:flutter_test/flutter_test.dart';

const Province _province = Province(id: 1, title: 'Toshkent');
const Region _region = Region(id: 2, title: 'Chilonzor');
const Village _village = Village(id: 3, title: 'Oqtepa');
const WorkplaceInfo _workplace = WorkplaceInfo(
  id: 4,
  name: 'Ishonch',
  category: WorkplaceCategory(id: 1, name: 'Savdo'),
);

CustomerForm _full() => const CustomerForm(
  customerId: 7,
  province: _province,
  region: _region,
  village: _village,
  workplace: _workplace,
  street: 'Bunyodkor',
  houseNumber: '12A',
  mainPhone: '+998 90 123-45-67',
  relativePhone: '+998 91 123-45-67',
  relativeKind: RelativeKind.brother,
  friendPhone: '+998 93 123-45-67',
);

void main() {
  group('issue', () {
    test('to‘liq forma', () => expect(_full().issue, CustomerFormIssue.none));

    test('viloyat yo‘q', () {
      expect(const CustomerForm(customerId: 1).issue, CustomerFormIssue.provinceMissing);
    });

    test('tuman yo‘q', () {
      expect(const CustomerForm(customerId: 1, province: _province).issue, CustomerFormIssue.regionMissing);
    });

    test('ko‘cha faqat bo‘shliqdan iborat', () {
      expect(_full().copyWith(street: '   ').issue, CustomerFormIssue.streetMissing);
    });

    test('raqam to‘liq emas', () {
      expect(_full().copyWith(mainPhone: '+998 90 123').issue, CustomerFormIssue.mainPhoneInvalid);
    });

    test('qarindosh kimligi tanlanmagan', () {
      const CustomerForm form = CustomerForm(
        customerId: 7,
        province: _province,
        region: _region,
        village: _village,
        workplace: _workplace,
        street: 'Bunyodkor',
        houseNumber: '12A',
        mainPhone: '+998 90 123-45-67',
        relativePhone: '+998 91 123-45-67',
        friendPhone: '+998 93 123-45-67',
      );

      expect(form.issue, CustomerFormIssue.relativeKindMissing);
    });
  });

  group('bog‘liq maydonlar', () {
    test('viloyat o‘zgarsa tuman, mahalla va ish joyi bekor bo‘ladi', () {
      final CustomerForm changed = _full().withProvince(const Province(id: 9, title: 'Andijon'));

      expect(changed.region, isNull);
      expect(changed.village, isNull);
      expect(changed.workplace, isNull);
    });

    test('tuman o‘zgarsa mahalla va ish joyi bekor bo‘ladi, viloyat qoladi', () {
      final CustomerForm changed = _full().withRegion(const Region(id: 9, title: 'Yunusobod'));

      expect(changed.province, _province);
      expect(changed.village, isNull);
      expect(changed.workplace, isNull);
    });
  });

  group('toParams', () {
    test('to‘liq formadan yasaladi', () {
      final CustomerUpdateParams? params = _full().toParams(isEdit: true);

      expect(params?.customerId, 7);
      expect(params?.villageId, 3);
      expect(params?.isEdit, isTrue);
      expect(params?.relativeKind, RelativeKind.brother);
    });

    test('to‘liq bo‘lmagan formadan null', () {
      expect(const CustomerForm(customerId: 1).toParams(isEdit: false), isNull);
    });
  });

  group('CustomerForm.of', () {
    test('telefonlarni izohiga qarab ajratadi', () {
      final CustomerInfo info = CustomerInfo(
        id: 7,
        fullName: 'Test',
        inps: '',
        passportNumber: '',
        birthDay: '',
        mainAddress: '',
        phones: const <PhoneNumber>[
          PhoneNumber(id: 1, phone: '+998901234567', isMain: true, comment: ''),
          PhoneNumber(id: 2, phone: '+998911234567', isMain: false, comment: 'Akasi'),
          PhoneNumber(id: 3, phone: '+998931234567', isMain: false, comment: ''),
        ],
        passportGiven: '',
        passportExpire: '',
        workplace: _workplace,
        province: _province,
        region: _region,
        village: _village,
        houseNumber: '12A',
        street: 'Bunyodkor',
        passportType: false,
      );

      final CustomerForm form = CustomerForm.of(info);

      expect(form.mainPhone, '+998901234567');
      expect(form.relativePhone, '+998911234567');
      expect(form.relativeKind, RelativeKind.brother);
      expect(form.friendPhone, '+998931234567');
    });

    test('id nol bo‘lgan tanlov tanlanmagan hisoblanadi', () {
      final CustomerInfo info = CustomerInfo(
        id: 7,
        fullName: 'Test',
        inps: '',
        passportNumber: '',
        birthDay: '',
        mainAddress: '',
        phones: const <PhoneNumber>[],
        passportGiven: '',
        passportExpire: '',
        workplace: const WorkplaceInfo(id: 0, name: '', category: WorkplaceCategory(id: 0, name: '')),
        province: const Province(id: 0, title: ''),
        region: const Region(id: 0, title: ''),
        village: const Village(id: 0, title: ''),
        houseNumber: '',
        street: '',
        passportType: false,
      );

      final CustomerForm form = CustomerForm.of(info);

      expect(form.province, isNull);
      expect(form.workplace, isNull);
    });
  });

  test('flexData formadan paramsga o‘tadi', () {
    final CustomerForm form = _full().copyWith();
    expect(form.toParams(isEdit: false)?.flexData, '');

    const CustomerForm withFlex = CustomerForm(
      customerId: 7,
      flexData: '{"a":1}',
      province: _province,
      region: _region,
      village: _village,
      workplace: _workplace,
      street: 'Bunyodkor',
      houseNumber: '12A',
      mainPhone: '+998 90 123-45-67',
      relativePhone: '+998 91 123-45-67',
      relativeKind: RelativeKind.brother,
      friendPhone: '+998 93 123-45-67',
    );
    expect(withFlex.toParams(isEdit: false)?.flexData, '{"a":1}');
  });

  test('RelativeKind.fromTitle notanish matnda null', () {
    expect(RelativeKind.fromTitle('Qo‘shnisi'), isNull);
    expect(RelativeKind.fromTitle('Akasi'), RelativeKind.brother);
  });
}
