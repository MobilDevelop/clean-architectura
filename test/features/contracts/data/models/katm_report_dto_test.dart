import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/features/contracts/data/models/katm_report_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ichki ro‘yxatlar saqlanadi, ichma-ich obyekt tashlanadi', () {
    final KatmReport report = KatmReportDto(<String, dynamic>{
      'state': 'available',
      'layout': <dynamic>[
        <String, dynamic>{'key': 'contracts', 'title': 'Shartnomalar'},
      ],
      'contracts': <dynamic>[
        <String, dynamic>{
          'org_name': 'Bank',
          'amount': '12000000',
          'contract_id': '01180',
          'ignored': <String, dynamic>{'a': 1},
          'balances': <dynamic>[
            <String, dynamic>{'month': '01.2025', 'begin_sum': '100', 'end_sum': '90'},
          ],
          'securities': <dynamic>[],
        },
      ],
    }).toEntity();

    final KatmTable? table = report.tableOf('contracts');
    expect(table?.rows.length, 1);

    final KatmRow row = table!.rows.first;

    // Summa bo‘linmaydi — javob so‘mda keladi.
    expect(row.valueOf('amount'), '12000000');
    expect(row.field('amount')?.isMoney, isTrue);

    // Kod maydoni tegilmaydi.
    expect(row.valueOf('contract_id'), '01180');

    // Ichma-ich obyekt qatorga tushmaydi.
    expect(row.field('ignored'), isNull);

    // Bo‘sh bo‘lmagan ichki ro‘yxat saqlanadi, bo‘shi esa yo‘q.
    expect(row.hasNested, isTrue);
    expect(row.nestedOf('balances').length, 1);
    expect(row.nestedOf('balances').first.valueOf('month'), '01.2025');
    expect(row.nestedOf('securities'), isEmpty);
  });

  test('open_contracts items va totals bilan keladi', () {
    final KatmReport report = KatmReportDto(<String, dynamic>{
      'layout': <dynamic>[
        <String, dynamic>{'key': 'open_contracts', 'title': 'Ochiq'},
      ],
      'open_contracts': <String, dynamic>{
        'items': <dynamic>[
          <String, dynamic>{'org_name': 'Bank'},
        ],
        'totals': <String, dynamic>{'total_debt_sum': '45000000'},
      },
    }).toEntity();

    final KatmTable? table = report.tableOf('open_contracts');
    expect(table?.rows.length, 1);
    expect(table?.totals?.valueOf('total_debt_sum'), '45000000');
  });

  test('shkala kelmasa gauge chizilmaydi', () {
    final KatmReport report = KatmReportDto(<String, dynamic>{'scoring': <String, dynamic>{'grade': 300}}).toEntity();

    expect(report.scoring.grade, 300);
    expect(report.scoring.hasScale, isFalse);
  });
}
