import 'package:colloborator_v3/features/contract_create/data/models/guarantor_instruments_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('turlar, karta va qoidalar o‘qiladi', () {
    final GuarantorInstruments result = GuarantorInstrumentsDto(<String, dynamic>{
      'types': <dynamic>['norasmiy', 'p2p'],
      'p2p': <String, dynamic>{
        'card_number_mask': '8600 **** **** 1234',
        'expire': '07/30',
        'phone_number': '998901234567',
      },
      'rules': <String, dynamic>{
        'mutually_exclusive': <dynamic>[
          <dynamic>['norasmiy', 'p2p'],
        ],
      },
    }).toEntity();

    expect(result.types, <InstrumentType>{InstrumentType.informal, InstrumentType.p2p});
    expect(result.card?.mask, '8600 **** **** 1234');
    expect(result.exclusive.single, <InstrumentType>{InstrumentType.informal, InstrumentType.p2p});
  });

  /// `PUT` to'liq almashtiradi: tanilmagan tur tushib qolsa serverdagi
  /// instrument jimgina o'chib ketardi.
  test('tanilmagan tur saqlanadi va qaytariladi', () {
    final GuarantorInstruments result = GuarantorInstrumentsDto(<String, dynamic>{
      'types': <dynamic>['norasmiy', 'ipoteka'],
    }).toEntity();

    expect(result.types, <InstrumentType>{InstrumentType.informal});
    expect(result.unknown, <String>{'ipoteka'});

    final SaveInstrumentsParams params = SaveInstrumentsParams(
      contractId: 1,
      clientId: 2,
      types: result.types,
      card: null,
      unknown: result.unknown,
    );

    expect(params.codes, <String>['norasmiy', 'ipoteka']);
  });

  test('bo‘sh javob yiqilmaydi', () {
    final GuarantorInstruments result = GuarantorInstrumentsDto(const <String, dynamic>{}).toEntity();

    expect(result.types, isEmpty);
    expect(result.unknown, isEmpty);
    expect(result.card, isNull);
    expect(result.exclusive, isEmpty);
  });

  /// Juftlikdagi tur tanilmasa taqiqni ilova tekshira olmaydi — backend
  /// `409` bilan aytadi, shuning uchun bunday juftlik tashlanadi.
  test('tanilmagan tur bo‘lgan juftlik qoidaga kirmaydi', () {
    final GuarantorInstruments result = GuarantorInstrumentsDto(<String, dynamic>{
      'rules': <String, dynamic>{
        'mutually_exclusive': <dynamic>[
          <dynamic>['norasmiy', 'ipoteka'],
        ],
      },
    }).toEntity();

    expect(result.exclusive, isEmpty);
  });
}
