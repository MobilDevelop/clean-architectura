import 'package:colloborator_v3/features/contract_create/data/models/contract_details_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('to‘liq javob o‘qiladi', () {
    final ContractDetails details = ContractDetailsDto(<String, dynamic>{
      'id': 77,
      'status_id': 11,
      'term': 6,
      'payment_day': 15,
      'formal': true,
      'checked_car_income': false,
      'file_url': 'https://example.uz/a.pdf',
      'has_benefit': true,
      'benefit': <String, dynamic>{
        'contract_id': 77,
        'required_amount': '50000',
        'available_amount': '120000',
        'used_amount': '0',
      },
      'client': <String, dynamic>{'fio': 'ABDULLAYEV BOTIR', 'workplace_category_id': 3},
      'plastic_card': <String, dynamic>{
        'id': 5,
        'card_number': '8600 **** **** 1234',
        'phone_number': '+998901234567',
        'validity_month': 9,
        'validity_year': 28,
      },
      'specialTariff': <String, dynamic>{'id': 2, 'name': 'Aksiya', 'active': true},
      'contract_products': <dynamic>[
        <String, dynamic>{
          'id': 1,
          'partner': <String, dynamic>{'id': 4, 'name': 'Texnomart'},
          'category': <String, dynamic>{'id': 7, 'name': 'Telefon'},
          'brand': <String, dynamic>{'id': 9, 'name': 'Samsung'},
          'product_variant': <String, dynamic>{'id': 11, 'name': 'A54 128GB'},
          'price': '3000000',
          'count': '2',
          'devices': <dynamic>['111111111111111'],
        },
      ],
      'guarantors': <dynamic>[
        <String, dynamic>{'id': 21, 'fio': 'KARIMOV ALI', 'passport_series_number': 'AA1234567'},
      ],
      'mib_fail_reason': '',
      'katm_fail_reason': 'Qarzdorlik bor',
    }).toEntity();

    expect(details.id, 77);
    expect(details.clientName, 'ABDULLAYEV BOTIR');
    expect(details.workplaceCategoryId, 3);
    expect(details.hasFile, isTrue);

    // Narx va miqdor satr sifatida keladi — butun songa o‘giriladi.
    expect(details.products.single.price, 3000000);
    expect(details.products.single.count, 2);
    expect(details.products.single.total, 6000000);
    expect(details.total, 6000000);

    expect(details.guarantors.single.fullName, 'KARIMOV ALI');
    expect(details.card.expiry, '09/28');
    expect(details.tariff.name, 'Aksiya');
    // Bonus obyektida summa uch xil maydonda keladi: talab qilingan,
    // mavjud limit va ishlatilgan.
    expect(details.benefit?.contractId, 77);
    expect(details.benefit?.requiredAmount, 50000);
    expect(details.benefit?.availableAmount, 120000);
    expect(details.katmFailReason, 'Qarzdorlik bor');
  });

  test('maxsus tarif snake_case bilan ham o‘qiladi', () {
    final ContractDetails details = ContractDetailsDto(<String, dynamic>{
      'special_tariff': <String, dynamic>{'id': 3, 'name': 'Yozgi', 'active': true},
    }).toEntity();

    expect(details.tariff.id, 3);
    expect(details.tariff.name, 'Yozgi');
  });

  test('bo‘sh javob yiqilmaydi', () {
    final ContractDetails details = ContractDetailsDto(const <String, dynamic>{}).toEntity();

    expect(details.products, isEmpty);
    expect(details.guarantors, isEmpty);
    expect(details.card.isEmpty, isTrue);
    expect(details.tariff.isEmpty, isTrue);
    expect(details.benefit, isNull);
    expect(details.total, 0);
    expect(details.hasFile, isFalse);
  });

  test('bonus bayrog‘i yo‘q bo‘lsa bonus ham yo‘q', () {
    final ContractDetails details = ContractDetailsDto(<String, dynamic>{
      'benefit': <String, dynamic>{'required_amount': '50000'},
    }).toEntity();

    expect(details.benefit, isNull);
  });

  test('kasrli narx butun so‘mga tushadi', () {
    final ContractDetails details = ContractDetailsDto(<String, dynamic>{
      'contract_products': <dynamic>[
        <String, dynamic>{'price': '1800000.00', 'count': 1},
      ],
    }).toEntity();

    expect(details.products.single.price, 1800000);
  });

  // `status_id` `POST` va `PUT` orasidagi mezon. Ilgari u `0` ga tushib,
  // `0 != draftStatus` bo'lgani uchun YANGI shartnoma «tahrirlangan» deb
  // hisoblanib `PUT` bilan yuborilardi.
  test('status kelmasa statusCode null bo‘ladi', () {
    final ContractDetails details = ContractDetailsDto(const <String, dynamic>{}).toEntity();

    expect(details.statusCode, isNull);
  });

  test('status kelsa o‘qiladi', () {
    final ContractDetails details = ContractDetailsDto(
      const <String, dynamic>{'status_id': 7},
    ).toEntity();

    expect(details.statusCode, 7);
  });

  // `?? 0` bo'lsa menejer qarori 0-shartnomaga ketardi.
  test('bonus contract_id siz yasalmaydi', () {
    final ContractDetails details = ContractDetailsDto(<String, dynamic>{
      'has_benefit': true,
      'benefit': <String, dynamic>{'required_amount': '50000'},
    }).toEntity();

    expect(details.benefit, isNull);
  });
}
