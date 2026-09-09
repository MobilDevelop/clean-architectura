import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_file.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:equatable/equatable.dart';

/// Bo'limlarning umumiy qismi: serverdagi yozuv id si va hujjatlar.
///
/// `editId` noldan farqli bo'lsa yozuv allaqachon mavjud va `PUT` ishlatiladi.
sealed class UnderwriterForm extends Equatable {
  const UnderwriterForm({required this.editId, required this.files});

  /// Serverdagi yozuv id si. `0` — hali yaratilmagan.
  final int editId;

  final List<UnderwriterFile> files;

  UnderwriterKind get kind;

  /// Hujjatlar ro'yxatini almashtiradi. Yuklashdan keyin kalitlar shu orqali
  /// yoziladi — bloc har bo'lim uchun alohida shox yozmasligi kerak.
  UnderwriterForm withFiles(List<UnderwriterFile> value);

  bool get isFull => files.length >= UnderwriterFileRule.maxCount;

  /// Saqlashga to'sqinlik qiladigan birinchi kamchilik.
  UnderwriterIssue get issue => files.isEmpty ? UnderwriterIssue.noFiles : UnderwriterIssue.none;
}

/// Oylik ish haqi qatori.
final class SalaryRow extends Equatable {
  const SalaryRow({required this.year, required this.month, required this.amount});

  final int year;
  final int month;

  /// Butun so'mda.
  final int amount;

  SalaryRow withAmount(int value) => SalaryRow(year: year, month: month, amount: value);

  @override
  List<Object?> get props => [year, month, amount];
}

final class SalaryForm extends UnderwriterForm {
  const SalaryForm({required super.editId, required super.files, required this.rows});

  /// Oxirgi olti oy, yangisidan eskisiga. Joriy oy kirmaydi — u hali
  /// tugamagan va uning ish haqi hujjatda bo'lmaydi.
  ///
  /// Bugungi sana tashqaridan beriladi: aks holda test bugun o'tib, ertaga
  /// yiqiladi (9.4).
  factory SalaryForm.months(DateTime today) => SalaryForm(
    editId: 0,
    files: const <UnderwriterFile>[],
    rows: List<SalaryRow>.generate(monthCount, (int i) {
      final DateTime month = DateTime(today.year, today.month - (i + 1));

      return SalaryRow(year: month.year, month: month.month, amount: 0);
    }),
  );

  static const int monthCount = 6;

  final List<SalaryRow> rows;

  @override
  UnderwriterKind get kind => UnderwriterKind.salary;

  SalaryForm withRow(int index, int amount) => SalaryForm(
    editId: editId,
    files: files,
    rows: <SalaryRow>[
      for (int i = 0; i < rows.length; i++) i == index ? rows[i].withAmount(amount) : rows[i],
    ],
  );

  @override
  SalaryForm withFiles(List<UnderwriterFile> value) =>
      SalaryForm(editId: editId, files: value, rows: rows);

  /// Server qatorlarni bermagan bo'lsa oxirgi olti oyni yaratadi.
  SalaryForm ensureRows(DateTime today) =>
      rows.isEmpty ? SalaryForm(editId: editId, files: files, rows: SalaryForm.months(today).rows) : this;

  @override
  List<Object?> get props => [editId, files, rows];
}

final class PensionForm extends UnderwriterForm {
  const PensionForm({required super.editId, required super.files, required this.amount});

  const PensionForm.empty() : this(editId: 0, files: const <UnderwriterFile>[], amount: 0);

  /// Butun so'mda.
  final int amount;

  @override
  UnderwriterKind get kind => UnderwriterKind.pension;

  @override
  UnderwriterIssue get issue {
    if (files.isEmpty) return UnderwriterIssue.noFiles;
    if (amount <= 0) return UnderwriterIssue.amountMissing;

    return UnderwriterIssue.none;
  }

  @override
  PensionForm withFiles(List<UnderwriterFile> value) => copyWith(files: value);

  PensionForm copyWith({List<UnderwriterFile>? files, int? amount}) =>
      PensionForm(editId: editId, files: files ?? this.files, amount: amount ?? this.amount);

  @override
  List<Object?> get props => [editId, files, amount];
}

/// Talaba guvohnomasi — faqat hujjat, boshqa maydon yo'q.
final class StudentForm extends UnderwriterForm {
  const StudentForm({required super.editId, required super.files});

  const StudentForm.empty() : this(editId: 0, files: const <UnderwriterFile>[]);

  @override
  UnderwriterKind get kind => UnderwriterKind.student;

  @override
  StudentForm withFiles(List<UnderwriterFile> value) => StudentForm(editId: editId, files: value);

  @override
  List<Object?> get props => [editId, files];
}

final class MilitaryForm extends UnderwriterForm {
  const MilitaryForm({required super.editId, required super.files, required this.position});

  const MilitaryForm.empty()
    : this(editId: 0, files: const <UnderwriterFile>[], position: const MilitaryPosition(id: 0, name: '', amount: 0));

  /// Tanlangan lavozim. Summa ham shundan olinadi.
  final MilitaryPosition position;

  @override
  UnderwriterKind get kind => UnderwriterKind.military;

  @override
  UnderwriterIssue get issue {
    if (files.isEmpty) return UnderwriterIssue.noFiles;
    if (position.isEmpty) return UnderwriterIssue.positionMissing;

    return UnderwriterIssue.none;
  }

  @override
  MilitaryForm withFiles(List<UnderwriterFile> value) => copyWith(files: value);

  MilitaryForm copyWith({List<UnderwriterFile>? files, MilitaryPosition? position}) =>
      MilitaryForm(editId: editId, files: files ?? this.files, position: position ?? this.position);

  @override
  List<Object?> get props => [editId, files, position];
}

final class CarForm extends UnderwriterForm {
  const CarForm({
    required super.editId,
    required super.files,
    required this.brand,
    required this.model,
    required this.year,
  });

  const CarForm.empty()
    : this(
        editId: 0,
        files: const <UnderwriterFile>[],
        brand: const UnderwriterOption(id: 0, name: ''),
        model: const UnderwriterOption(id: 0, name: ''),
        year: 0,
      );

  /// Eng eski ishlab chiqarilgan yil.
  static const int firstYear = 2000;

  final UnderwriterOption brand;
  final UnderwriterOption model;

  /// `0` — tanlanmagan.
  final int year;

  /// Joriy yildan [firstYear] gacha. Bugungi sana tashqaridan (9.4).
  static List<int> yearsUntil(DateTime today) =>
      List<int>.generate(today.year - firstYear + 1, (int i) => today.year - i);

  @override
  UnderwriterKind get kind => UnderwriterKind.car;

  @override
  UnderwriterIssue get issue {
    if (files.isEmpty) return UnderwriterIssue.noFiles;
    if (brand.isEmpty) return UnderwriterIssue.brandMissing;
    if (model.isEmpty) return UnderwriterIssue.modelMissing;
    if (year == 0) return UnderwriterIssue.yearMissing;

    return UnderwriterIssue.none;
  }

  /// Brend o'zgarsa marka bekor qilinadi — u eski brendga tegishli edi.
  CarForm withBrand(UnderwriterOption value) => CarForm(
    editId: editId,
    files: files,
    brand: value,
    model: const UnderwriterOption(id: 0, name: ''),
    year: year,
  );

  @override
  CarForm withFiles(List<UnderwriterFile> value) => copyWith(files: value);

  CarForm copyWith({List<UnderwriterFile>? files, UnderwriterOption? model, int? year}) => CarForm(
    editId: editId,
    files: files ?? this.files,
    brand: brand,
    model: model ?? this.model,
    year: year ?? this.year,
  );

  @override
  List<Object?> get props => [editId, files, brand, model, year];
}
