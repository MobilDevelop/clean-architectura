import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_forms.dart';
import 'package:colloborator_v3/features/underwriter/domain/entities/underwriter_kind.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:equatable/equatable.dart';

/// Ekran qanday ochilgani.
///
/// Barcha maydonlar oddiy tip: marshrut argumenti orqali keladi va shu sababli
/// bu feature `contract_create` ni ham, `contracts` ni ham import qilmaydi (1.3).
final class UnderwriterArgs extends Equatable {
  const UnderwriterArgs({
    required this.contractId,
    required this.clientId,
    required this.workplaceCategoryId,
    required this.isFormal,
    required this.hasCard,
  });

  final int contractId;
  final int clientId;

  /// Guvohnoma bo'limi shu toifaga qarab ochiladi.
  final int workplaceCategoryId;

  /// Rasmiy daromadmi. Talaba bo'limi shunga bog'liq.
  final bool isFormal;

  /// Shartnomaga karta biriktirilganmi.
  final bool hasCard;

  @override
  List<Object?> get props => [contractId, clientId, workplaceCategoryId, isFormal, hasCard];
}

/// Qaysi bo'limlar ko'rinishi.
///
/// Sof Dart qaror: widget uni hisoblamaydi (6.7). Flex'da bu mantiq ikkiga
/// bo'lingan edi — bir qismi chaqiruvchi ekranda, bir qismi qabul qiluvchida,
/// va ikkinchisi birinchisining natijasini qayta hisoblardi.
abstract final class UnderwriterPlan {
  /// Guvohnoma shu ish joyi toifalarida so'raladi.
  static const Set<int> certificateCategories = <int>{4, 5, 6};

  /// Ko'rinish tartibida.
  static List<UnderwriterKind> of(UnderwriterArgs args) {
    final bool hasCertificate = certificateCategories.contains(args.workplaceCategoryId);

    return <UnderwriterKind>[
      UnderwriterKind.salary,
      UnderwriterKind.car,
      // Pensiya va Guvohnoma bir-birini istisno qiladi.
      if (hasCertificate) UnderwriterKind.military else UnderwriterKind.pension,
      // Talaba: rasmiy daromad, kartasiz va guvohnoma so'ralmaydigan holat.
      if (args.isFormal && !args.hasCard && !hasCertificate) UnderwriterKind.student,
    ];
  }
}

/// `GET underwriters?contract_id=` javobi — beshala bo'lim birdaniga.
final class UnderwriterData extends Equatable {
  const UnderwriterData({
    required this.salary,
    required this.pension,
    required this.student,
    required this.military,
    required this.car,
  });

  final SalaryForm salary;
  final PensionForm pension;
  final StudentForm student;
  final MilitaryForm military;
  final CarForm car;

  /// Kindiga qarab bo'limni qaytaradi.
  UnderwriterForm formOf(UnderwriterKind kind) => switch (kind) {
    UnderwriterKind.salary => salary,
    UnderwriterKind.pension => pension,
    UnderwriterKind.student => student,
    UnderwriterKind.military => military,
    UnderwriterKind.car => car,
  };

  /// Bitta bo'limni almashtiradi. `switch` sealed tip ustida — yangi bo'lim
  /// qo'shilsa kompilyatsiya xatosi chiqadi.
  UnderwriterData withForm(UnderwriterForm form) => switch (form) {
    SalaryForm() => UnderwriterData(salary: form, pension: pension, student: student, military: military, car: car),
    PensionForm() => UnderwriterData(salary: salary, pension: form, student: student, military: military, car: car),
    StudentForm() => UnderwriterData(salary: salary, pension: pension, student: form, military: military, car: car),
    MilitaryForm() => UnderwriterData(salary: salary, pension: pension, student: student, military: form, car: car),
    CarForm() => UnderwriterData(salary: salary, pension: pension, student: student, military: military, car: form),
  };

  @override
  List<Object?> get props => [salary, pension, student, military, car];
}

/// Saqlash natijasi.
///
/// «Serverga yozildi» va «qayta o'qildi» — bir xil narsa emas. Ikkalasini
/// bitta `Err` ga qo'shib yuborish xavfli: «Qayta urinish» takroriy `POST`
/// yuborib, serverda ikkinchi yozuv qoldiradi.
final class SaveOutcome extends Equatable {
  const SaveOutcome({required this.data, required this.reloadFailure});

  /// Qayta o'qilgan holat. `null` — yozuv ketdi, lekin o'qish yiqildi.
  final UnderwriterData? data;

  final Failure? reloadFailure;

  @override
  List<Object?> get props => [data, reloadFailure];
}

/// Bitta bo'limni saqlash.
final class SaveUnderwriterParams extends Equatable {
  const SaveUnderwriterParams({required this.args, required this.form});

  final UnderwriterArgs args;
  final UnderwriterForm form;

  @override
  List<Object?> get props => [args, form];
}

/// Ekran uchun kerak bo'ladigan ma'lumotnomalar.
final class UnderwriterReferences extends Equatable {
  const UnderwriterReferences({required this.positions, required this.brands, required this.models});

  const UnderwriterReferences.empty()
    : positions = const <MilitaryPosition>[],
      brands = const <UnderwriterOption>[],
      models = const <UnderwriterOption>[];

  final List<MilitaryPosition> positions;
  final List<UnderwriterOption> brands;

  /// Saqlangan brend bo'lsa uning markalari ham darhol keladi.
  final List<UnderwriterOption> models;

  @override
  List<Object?> get props => [positions, brands, models];
}

/// Ma'lumotnomalarni so'rash sharti.
final class ReferencesQuery extends Equatable {
  const ReferencesQuery({required this.needsPositions, required this.brandId});

  /// Guvohnoma bo'limi ochilmasa lavozimlar so'ralmaydi.
  final bool needsPositions;

  /// `0` — brend tanlanmagan, markalar kerak emas.
  final int brandId;

  @override
  List<Object?> get props => [needsPositions, brandId];
}
