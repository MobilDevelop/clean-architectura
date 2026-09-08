import 'package:colloborator_v3/features/contract_create/data/models/schedule_dto.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/schedule_date_text.dart';
import 'package:flutter_test/flutter_test.dart';

ScheduleRow _row(Map<String, dynamic> json) => ScheduleRowDto.fromJson(json).toEntity();

void main() {
  group('sana', () {
    test('dd-MM-yyyy o‘qiladi', () {
      final ScheduleRow row = _row(<String, dynamic>{'number': 1, 'date': '15-01-2026', 'value': 1800000});

      expect(row.date, DateTime(2026, 1, 15));
      expect(row.amount, 1800000);
    });

    test('buzuq sana qatorni yo‘qotmaydi', () {
      for (final Object? bad in <Object?>['2026-01-15', '15/01/2026', '', null, '15-13-2026', '32-01-2026']) {
        final ScheduleRow row = _row(<String, dynamic>{'number': 2, 'date': bad, 'value': 500});

        // Sana yo'q, lekin qator o'z summasi bilan qoladi (5.8).
        expect(row.date, isNull, reason: 'kirish: $bad');
        expect(row.amount, 500);
      }
    });
  });

  group('ekrandagi matn', () {
    test('o‘zbekcha oy nomi bilan chiqadi', () {
      expect(ScheduleDateText.of(DateTime(2026, 1, 15)), '15-yanvar 2026');
      expect(ScheduleDateText.of(DateTime(2026, 2, 1)), '1-fevral 2026');
      expect(ScheduleDateText.of(DateTime(2026, 12, 31)), '31-dekabr 2026');
    });

    test('sana yo‘q bo‘lsa chiziqcha', () => expect(ScheduleDateText.of(null), '—'));
  });

  test('summalar bo‘linmaydi — javob so‘mda keladi', () {
    final ScheduleRow row = _row(<String, dynamic>{'number': 1, 'date': '01-03-2026', 'value': '2450000'});

    expect(row.amount, 2450000);
  });
}
