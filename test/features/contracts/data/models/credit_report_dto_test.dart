import 'package:colloborator_v3/features/contracts/data/models/credit_report_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditParticipantDto', () {
    test('to‘liq yozuv o‘qiladi', () {
      final dto = CreditParticipantDto.fromJson(<String, dynamic>{
        'client_id': 55,
        'role': 'client',
        'fio': 'ABDULLAYEV BOTIR',
        'inps': '12345678901234',
        'mib': <String, dynamic>{'state': 'has_debt', 'total': 150000, 'debts_qty': 2},
        'katm': <String, dynamic>{'state': 'available', 'scoring_grade': 7, 'all_debt_sum': 200000},
      });

      final entity = dto.toEntity();

      expect(entity.clientId, 55);
      expect(entity.mib.total, 150000);
      expect(entity.katm.scoringGrade, 7);
    });

    test('client_id siz yiqiladi', () {
      expect(
        () => CreditParticipantDto.fromJson(<String, dynamic>{'role': 'client', 'fio': 'ABDULLAYEV'}),
        throwsFormatException,
      );
    });

    // Bu xato emas — hali tekshirilmagan ishtirokchida kalit kelmaydi.
    test('mib/katm kaliti kelmasa "hali tekshirilmagan" bo‘ladi', () {
      final dto = CreditParticipantDto.fromJson(<String, dynamic>{'client_id': 1, 'role': 'client'});

      expect(dto.toEntity().mib.state.name, 'notChecked');
      expect(dto.toEntity().katm.state.name, 'notChecked');
    });

    test('mib.total kalit bor-u son emas — yiqiladi', () {
      expect(
        () => CreditParticipantDto.fromJson(<String, dynamic>{
          'client_id': 1,
          'mib': <String, dynamic>{'state': 'has_debt', 'total': 'noma\'lum'},
        }),
        throwsFormatException,
      );
    });
  });

  group('CreditReportsDto', () {
    test('bitta ishtirokchi buzuq bo‘lsa butun javob yiqiladi', () {
      expect(
        () => CreditReportsDto.fromJson(<String, dynamic>{
          'participants': <dynamic>[
            <String, dynamic>{'client_id': 1, 'role': 'client'},
            <String, dynamic>{'role': 'guarantor'},
          ],
        }),
        throwsFormatException,
      );
    });
  });
}
