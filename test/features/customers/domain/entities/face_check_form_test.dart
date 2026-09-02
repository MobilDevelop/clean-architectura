import 'package:colloborator_v3/features/customers/domain/entities/face_check_form.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime today = DateTime(2026, 9, 1);

  const List<(String, String, String, FaceCheckIssue)> cases = <(String, String, String, FaceCheckIssue)>[
    ('A', '1234567', '01.01.1990', FaceCheckIssue.incompleteSeries),
    ('', '1234567', '01.01.1990', FaceCheckIssue.incompleteSeries),
    ('AA', '12345', '01.01.1990', FaceCheckIssue.incompleteNumber),
    ('AA', '1234567', '01.01', FaceCheckIssue.incompleteDate),
    ('AA', '1234567', '31.02.2000', FaceCheckIssue.invalidDate),
    ('AA', '1234567', '00.01.1990', FaceCheckIssue.invalidDate),
    ('AA', '1234567', '01.13.1990', FaceCheckIssue.invalidDate),
    ('AA', '1234567', '29.02.2001', FaceCheckIssue.invalidDate),
    ('AA', '1234567', '01.01.2030', FaceCheckIssue.futureDate),
    ('AA', '1234567', '02.09.2026', FaceCheckIssue.futureDate),
    ('AA', '1234567', '29.02.2000', FaceCheckIssue.none),
    ('AA', '1234567', '01.01.1990', FaceCheckIssue.none),

    // 16 yosh chegarasi — bugun 2026-09-01
    ('AA', '1234567', '29.02.2024', FaceCheckIssue.tooYoung),
    ('AA', '1234567', '01.09.2010', FaceCheckIssue.none),
    ('AA', '1234567', '02.09.2010', FaceCheckIssue.tooYoung),
    ('AA', '1234567', '31.08.2010', FaceCheckIssue.none),
    ('AA', '1234567', '01.01.2015', FaceCheckIssue.tooYoung),
  ];

  for (final (String series, String number, String birthday, FaceCheckIssue expected) in cases) {
    test('$series$number  $birthday → ${expected.name}', () {
      expect(FaceCheckForm(series: series, number: number, birthday: birthday).issueAt(today), expected);
    });
  }

  test('passport seriya va raqamni birlashtiradi', () {
    expect(const FaceCheckForm(series: 'AA', number: '1234567').passport, 'AA1234567');
  });
}
