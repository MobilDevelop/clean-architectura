import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/models/card_confirmation_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/card_confirm_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/card_confirm_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepo implements CardConfirmRepository {
  int submits = 0;
  CardConfirmParams? last;

  @override
  Future<Result<CardConfirmation>> get(int contractId) async =>
      Err<CardConfirmation>(const UnknownFailure('test'));

  @override
  Future<Result<void>> submit(CardConfirmParams params) async {
    submits++;
    last = params;

    return const Ok<void>(null);
  }
}

const CardConfirmation _data = CardConfirmation(
  contractId: 55,
  cardId: 3,
  elmaApplicationId: 'app',
  elmaInstanceId: 'inst',
  phone: '998901234567',
  message: '',
  step: CardConfirmStep.otp,
  expiresAt: null,
  cardNumber: '8600000000000000',
  cardExpiry: '09/30',
  isOwnerMismatch: false,
);

void main() {
  group('DTO', () {
    // ELMA `state` ni satr bilan yuboradi va yangi kod qo'shishi mumkin —
    // noma'lum qiymat OTP deb qabul qilinadi.
    test('`state` bosqichga aylanadi, noma’lumi OTP', () {
      expect(CardConfirmStep.fromCode('2'), CardConfirmStep.resend);
      expect(CardConfirmStep.fromCode('4'), CardConfirmStep.cardNeeded);
      expect(CardConfirmStep.fromCode('1'), CardConfirmStep.otp);
      expect(CardConfirmStep.fromCode('77'), CardConfirmStep.otp);
    });

    // Flex `DateTime.parse` ni to'g'ridan-to'g'ri chaqirardi va buzuq sanada
    // istisno otardi.
    test('buzuq sana istisno otmaydi', () {
      final CardConfirmation data = CardConfirmationDto.fromJson(const <String, dynamic>{
        'sms_code_expired_time': 'kecha',
      }).toEntity();

      expect(data.expiresAt, isNull);
    });

    test('karta ma’lumoti ichma-ich obyektdan o‘qiladi', () {
      final CardConfirmation data = CardConfirmationDto.fromJson(const <String, dynamic>{
        'contract_id': 55,
        'phone_number': '+998 90 123-45-67',
        'card': <String, dynamic>{'card_number': '8600 0000 0000 0000', 'validity_date': '09/30'},
      }).toEntity();

      expect(data.contractId, 55);
      // Faqat raqamlar: so'rovga maskalangan matn ketmasligi kerak.
      expect(data.phone, '998901234567');
      expect(data.cardNumber, '8600000000000000');
      expect(data.cardExpiry, '09/30');
    });

    // `state` tekshirilmaydi: ELMA buni `"2"` bilan ham, `"4"` bilan ham
    // yuborishi mumkin.
    test('`card_owner_mismatch` bosqichdan qat’i nazar aniqlanadi', () {
      for (final String state in <String>['2', '4', '1']) {
        final CardConfirmation data = CardConfirmationDto.fromJson(<String, dynamic>{
          'state': state,
          'error_code': 'card_owner_mismatch',
        }).toEntity();

        expect(data.isOwnerMismatch, isTrue);
      }
    });
  });

  group('karta ma’lumoti', () {
    // Flex `int.parse(date.substring(0, 2))` qilardi — noto'g'ri kiritilgan
    // sanada istisno otardi.
    test('buzuq muddat istisno otmaydi', () {
      expect(const CardEntry(number: '', expiry: '', phone: '').month, 0);
      expect(const CardEntry(number: '', expiry: 'ab/cd', phone: '').month, 0);
      expect(const CardEntry(number: '', expiry: '09/30', phone: '').month, 9);
      expect(const CardEntry(number: '', expiry: '09/30', phone: '').year, 30);
    });

    test('kamchilik aniqlanadi', () {
      const CardEntry short = CardEntry(number: '8600', expiry: '09/30', phone: '998901234567');
      const CardEntry badMonth = CardEntry(number: '8600000000000000', expiry: '13/30', phone: '998901234567');
      const CardEntry shortPhone = CardEntry(number: '8600000000000000', expiry: '09/30', phone: '99890');
      const CardEntry good = CardEntry(number: '8600000000000000', expiry: '09/30', phone: '998901234567');

      expect(short.issueAt(DateTime(2026, 9, 12)), CardConfirmIssue.cardNumberShort);
      expect(badMonth.issueAt(DateTime(2026, 9, 12)), CardConfirmIssue.expiryInvalid);
      expect(shortPhone.issueAt(DateTime(2026, 9, 12)), CardConfirmIssue.phoneShort);
      expect(good.issueAt(DateTime(2026, 9, 12)), CardConfirmIssue.none);
    });
  });

  group('yuborish qoidalari', () {
    late _FakeRepo repo;
    late SubmitCardConfirmationUsecase submit;

    setUp(() {
      repo = _FakeRepo();
      submit = SubmitCardConfirmationUsecase(repo, () => DateTime(2026, 9, 12));
    });

    test('kodsiz yuborilmaydi', () async {
      final Result<void> result = await submit(
        const CardConfirmParams(confirmation: _data, action: CardConfirmAction.code),
      );

      expect(result, isA<Err<void>>());
      expect(repo.submits, 0);
    });

    // Karta tekshirilmasin belgilansa kod umuman kerak emas.
    test('kartani tekshirmaslik kodsiz ham ketadi', () async {
      final Result<void> result = await submit(
        const CardConfirmParams(confirmation: _data, action: CardConfirmAction.skipCard),
      );

      expect(result, isA<Ok<void>>());
      expect(repo.last?.action.value, '3');
    });

    test('to‘liq bo‘lmagan karta yuborilmaydi', () async {
      final Result<void> result = await submit(
        const CardConfirmParams(
          confirmation: _data,
          action: CardConfirmAction.saveCard,
          entry: CardEntry(number: '8600', expiry: '09/30', phone: '998901234567'),
        ),
      );

      expect(result, isA<Err<void>>());
      expect(repo.submits, 0);
    });

    // ELMA OTP yubormaydi va server har qanday davom etishni rad etadi —
    // so'rov umuman ketmasligi kerak.
    test('karta boshqa shaxsniki bo‘lsa hech qanday amal ketmaydi', () async {
      const CardConfirmation mismatch = CardConfirmation(
        contractId: 55,
        cardId: 3,
        elmaApplicationId: '',
        elmaInstanceId: '',
        phone: '',
        message: 'Karta boshqa shaxsga tegishli',
        step: CardConfirmStep.otp,
        expiresAt: null,
        cardNumber: '',
        cardExpiry: '',
        isOwnerMismatch: true,
      );

      for (final CardConfirmAction action in CardConfirmAction.values) {
        final Result<void> result = await submit(
          CardConfirmParams(confirmation: mismatch, action: action, code: '123456'),
        );

        expect(result, isA<Err<void>>());
      }

      expect(repo.submits, 0);
    });
  });
}
