import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_data.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:flutter_test/flutter_test.dart';

UnderwriterArgs _args({int category = 1, bool isFormal = true, bool hasCard = false}) =>
    UnderwriterArgs(
      contractId: 5,
      clientId: 42,
      workplaceCategoryId: category,
      isFormal: isFormal,
      hasCard: hasCard,
    );

const UnderwriterFile _file = UnderwriterFile(key: 'k', name: 'a.pdf');

void main() {
  group('qaysi bo‘limlar ochiladi', () {
    test('ish haqi va avtomobil har doim bor', () {
      expect(UnderwriterPlan.of(_args()), contains(UnderwriterKind.salary));
      expect(UnderwriterPlan.of(_args()), contains(UnderwriterKind.car));
    });

    test('guvohnoma faqat 4, 5, 6-toifada, pensiya esa qolganida', () {
      for (final int id in <int>[4, 5, 6]) {
        final List<UnderwriterKind> plan = UnderwriterPlan.of(_args(category: id));

        expect(plan, contains(UnderwriterKind.military));
        expect(plan, isNot(contains(UnderwriterKind.pension)));
      }

      final List<UnderwriterKind> other = UnderwriterPlan.of(_args(category: 3));
      expect(other, contains(UnderwriterKind.pension));
      expect(other, isNot(contains(UnderwriterKind.military)));
    });

    test('talaba: rasmiy, kartasiz va guvohnomasiz holatda', () {
      expect(UnderwriterPlan.of(_args()), contains(UnderwriterKind.student));
      expect(UnderwriterPlan.of(_args(isFormal: false)), isNot(contains(UnderwriterKind.student)));
      expect(UnderwriterPlan.of(_args(hasCard: true)), isNot(contains(UnderwriterKind.student)));
      // Guvohnoma so'ralganda talaba ko'rinmaydi.
      expect(UnderwriterPlan.of(_args(category: 5)), isNot(contains(UnderwriterKind.student)));
    });
  });

  group('ish haqi oylari', () {
    test('oxirgi olti oy, joriy oy kirmaydi', () {
      final SalaryForm form = SalaryForm.months(DateTime(2026, 3, 15));

      expect(form.rows.length, 6);
      expect(form.rows.first.month, 2);
      expect(form.rows.first.year, 2026);
      // Yil chegarasidan o'tadi.
      expect(form.rows.last.month, 9);
      expect(form.rows.last.year, 2025);
    });

    test('server qatorlarni bergan bo‘lsa yaratilmaydi', () {
      const SalaryForm loaded = SalaryForm(
        editId: 7,
        files: <UnderwriterFile>[],
        rows: <SalaryRow>[SalaryRow(year: 2026, month: 1, amount: 500)],
      );

      expect(loaded.ensureRows(DateTime(2026, 3)).rows.length, 1);
    });
  });

  group('saqlashga to‘sqinlik', () {
    test('hujjatsiz hech bir bo‘lim saqlanmaydi', () {
      expect(const StudentForm.empty().issue, UnderwriterIssue.noFiles);
      expect(const PensionForm.empty().issue, UnderwriterIssue.noFiles);
      expect(const CarForm.empty().issue, UnderwriterIssue.noFiles);
    });

    test('pensiyada summa talab qilinadi', () {
      const PensionForm form = PensionForm(editId: 0, files: <UnderwriterFile>[_file], amount: 0);

      expect(form.issue, UnderwriterIssue.amountMissing);
      expect(form.copyWith(amount: 100).issue, UnderwriterIssue.none);
    });

    test('avtomobilda tartib: brend, marka, yil', () {
      const CarForm base = CarForm(
        editId: 0,
        files: <UnderwriterFile>[_file],
        brand: UnderwriterOption(id: 0, name: ''),
        model: UnderwriterOption(id: 0, name: ''),
        year: 0,
      );

      expect(base.issue, UnderwriterIssue.brandMissing);

      final CarForm withBrand = base.withBrand(const UnderwriterOption(id: 1, name: 'Chevrolet'));
      expect(withBrand.issue, UnderwriterIssue.modelMissing);

      final CarForm withModel = withBrand.copyWith(model: const UnderwriterOption(id: 2, name: 'Nexia'));
      expect(withModel.issue, UnderwriterIssue.yearMissing);
      expect(withModel.copyWith(year: 2020).issue, UnderwriterIssue.none);
    });

    test('brend o‘zgarsa marka bekor qilinadi', () {
      const CarForm form = CarForm(
        editId: 0,
        files: <UnderwriterFile>[],
        brand: UnderwriterOption(id: 1, name: 'Chevrolet'),
        model: UnderwriterOption(id: 2, name: 'Nexia'),
        year: 2020,
      );

      expect(form.withBrand(const UnderwriterOption(id: 9, name: 'Kia')).model.isEmpty, isTrue);
    });
  });

  group('fayl chegarasi', () {
    test('uchtadan ortiq qabul qilinmaydi', () {
      expect(
        UnderwriterFileRule.check(count: 3, bytes: 100, extension: 'pdf'),
        FileIssue.tooMany,
      );
    });

    test('2 MB dan katta va notanish tur rad etiladi', () {
      expect(
        UnderwriterFileRule.check(count: 0, bytes: 3000000, extension: 'pdf'),
        FileIssue.tooLarge,
      );
      expect(
        UnderwriterFileRule.check(count: 0, bytes: 100, extension: 'docx'),
        FileIssue.wrongType,
      );
      expect(UnderwriterFileRule.check(count: 0, bytes: 100, extension: 'JPG'), FileIssue.none);
    });

    test('S3 uchun MIME kengaytmadan olinadi', () {
      expect(UnderwriterFileRule.mimeOf('pdf'), 'application/pdf');
      expect(UnderwriterFileRule.mimeOf('jpeg'), 'image/jpeg');
      expect(UnderwriterFileRule.mimeOf('png'), 'image/png');
    });
  });
}
