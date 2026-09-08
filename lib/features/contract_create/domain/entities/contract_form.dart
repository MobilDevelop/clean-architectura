import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:equatable/equatable.dart';

/// Ekran qaysi rejimda ochilgani.
///
/// Yangi shartnomada `contractId` boshida yo'q: qoralama birinchi tovar
/// qo'shilganda yaratiladi. Shu sababli u `null` bo'la oladi.
///
/// [canSkipKatm] shartnomalar ro'yxatidan keladi (`show_button_katm`) —
/// `GET loans/{id}` bu bayroqni qaytarmaydi, shuning uchun uni marshrut
/// argumentida olib yurishdan boshqa yo'l yo'q.
final class ContractCreateArgs extends Equatable {
  const ContractCreateArgs({required this.clientId, this.contractId, this.canSkipKatm = false});

  final int clientId;
  final int? contractId;
  final bool canSkipKatm;

  /// Mavjud shartnoma tahrirlanyapti — yuborishda `PUT` ishlatiladi.
  bool get isEdit => contractId != null;

  @override
  List<Object?> get props => [clientId, contractId, canSkipKatm];
}

enum ContractFormIssue { none, noProducts, paymentDayMissing, occupationMissing }

/// Shartnoma yozuvining o'zi — `POST /loans` va `PUT loans/{id}` yuboradigan
/// maydonlar.
///
/// Tovarlar, kafillar va karta bu yerda emas: ularning har biri o'z so'rovi
/// bilan darhol saqlanadi, bu maydonlar esa faqat yuborishda saqlanadi.
/// Ikkalasini bitta obyektga qo'shish "qaysi qiymat saqlangan" degan savolni
/// javobsiz qoldiradi.
final class ContractForm extends Equatable {
  const ContractForm({
    required this.termMonths,
    required this.paymentDays,
    required this.paymentDayIndex,
    required this.basis,
    required this.hasCarIncome,
    required this.occupation,
    required this.catalog,
  });

  const ContractForm.initial()
    : termMonths = defaultTerm,
      paymentDays = const <int>[],
      paymentDayIndex = 0,
      basis = IncomeBasis.formal,
      hasCarIncome = false,
      occupation = const OccupationType(id: 0, name: ''),
      catalog = const OccupationCatalog.empty();

  static const int minTerm = 1;
  static const int maxTerm = 12;
  static const int defaultTerm = 12;

  final int termMonths;

  /// Serverdan keladigan ruxsat etilgan kunlar.
  final List<int> paymentDays;

  /// Tanlangan kunning ro'yxatdagi o'rni — kunning o'zi emas.
  final int paymentDayIndex;

  final IncomeBasis basis;
  final bool hasCarIncome;

  /// Tanlangan qo'shimcha daromad turi.
  final OccupationType occupation;

  /// Serverdagi kasb ro'yxati va uning talab qilinishi.
  final OccupationCatalog catalog;

  /// Tanlangan kun. Ro'yxat bo'sh bo'lsa `0`.
  int get paymentDay =>
      paymentDayIndex >= 0 && paymentDayIndex < paymentDays.length ? paymentDays[paymentDayIndex] : 0;

  bool get canIncreaseTerm => termMonths < maxTerm;

  bool get canDecreaseTerm => termMonths > minTerm;

  /// Kasb turi shartnomaga biriktirilgan karta bo'lsa yoki daromad norasmiy
  /// bo'lsa so'raladi — va faqat server uni ko'rsatishga ruxsat bergan bo'lsa.
  bool isOccupationNeeded({required bool hasCard}) =>
      catalog.isRequired && (basis == IncomeBasis.informal || hasCard);

  /// Yuborishga to'sqinlik qilayotgan birinchi kamchilik.
  ///
  /// Tovarlar soni tashqaridan beriladi: ular formaning bir qismi emas,
  /// alohida resurs.
  ContractFormIssue issueAt({required int productCount, required bool hasCard}) {
    if (productCount == 0) return ContractFormIssue.noProducts;
    if (paymentDay == 0) return ContractFormIssue.paymentDayMissing;
    if (isOccupationNeeded(hasCard: hasCard) && occupation.isEmpty) return ContractFormIssue.occupationMissing;

    return ContractFormIssue.none;
  }

  ContractForm withTerm(int value) => copyWith(termMonths: value.clamp(minTerm, maxTerm));

  /// Serverdagi kunlar ro'yxati. [preferredDay] shartnomada allaqachon
  /// tanlangan kun — ro'yxatda topilmasa birinchisiga tushadi.
  ContractForm withPaymentDays(List<int> days, {int preferredDay = 0}) {
    final int found = days.indexOf(preferredDay);

    return copyWith(paymentDays: days, paymentDayIndex: found < 0 ? 0 : found);
  }

  ContractForm copyWith({
    int? termMonths,
    List<int>? paymentDays,
    int? paymentDayIndex,
    IncomeBasis? basis,
    bool? hasCarIncome,
    OccupationType? occupation,
    OccupationCatalog? catalog,
  }) => ContractForm(
    termMonths: termMonths ?? this.termMonths,
    paymentDays: paymentDays ?? this.paymentDays,
    paymentDayIndex: paymentDayIndex ?? this.paymentDayIndex,
    basis: basis ?? this.basis,
    hasCarIncome: hasCarIncome ?? this.hasCarIncome,
    occupation: occupation ?? this.occupation,
    catalog: catalog ?? this.catalog,
  );

  @override
  List<Object?> get props => [
    termMonths,
    paymentDays,
    paymentDayIndex,
    basis,
    hasCarIncome,
    occupation,
    catalog,
  ];
}
