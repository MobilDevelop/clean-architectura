import 'package:equatable/equatable.dart';

/// Ma'lumotnomadan tanlangan element: yetkazib beruvchi, toifa, brend, tovar.
final class CatalogItem extends Equatable {
  const CatalogItem({required this.id, required this.name});

  /// `0` — tanlanmagan.
  final int id;
  final String name;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name];
}

/// Shartnomadagi bitta tovar.
final class ContractProduct extends Equatable {
  const ContractProduct({
    required this.id,
    required this.supplier,
    required this.category,
    required this.brand,
    required this.variant,
    required this.price,
    required this.count,
    required this.imeis,
  });

  /// Shartnoma-tovar qatorining id si. `0` — hali saqlanmagan.
  final int id;

  final CatalogItem supplier;
  final CatalogItem category;
  final CatalogItem brand;
  final CatalogItem variant;

  /// Butun so'mda.
  final int price;

  final int count;
  final List<String> imeis;

  int get total => price * count;

  /// Serverda o'zgargan narx va miqdorni qo'llaydi. Toifa va tovar
  /// o'zgarmaydi — `update_loan_product` ularni qabul qilmaydi.
  ContractProduct withPriceAndCount({required int price, required int count}) => ContractProduct(
    id: id,
    supplier: supplier,
    category: category,
    brand: brand,
    variant: variant,
    price: price,
    count: count,
    imeis: imeis,
  );

  @override
  List<Object?> get props => [id, supplier, category, brand, variant, price, count, imeis];
}

/// Shartnomaga biriktirilgan plastik karta.
final class ContractCard extends Equatable {
  const ContractCard({
    required this.id,
    required this.number,
    required this.phone,
    required this.month,
    required this.year,
  });

  final int id;
  final String number;
  final String phone;

  /// Amal qilish muddati. `0` — kelmagan.
  final int month;
  final int year;

  bool get isEmpty => id == 0;

  /// `09/28`. Muddat kelmagan bo'lsa bo'sh satr.
  String get expiry =>
      month == 0 || year == 0 ? '' : '${month.toString().padLeft(2, '0')}/${year.toString().padLeft(2, '0')}';

  @override
  List<Object?> get props => [id, number, phone, month, year];
}

/// Shartnomaga biriktirilgan maxsus tarif.
final class AppliedTariff extends Equatable {
  const AppliedTariff({required this.id, required this.name, required this.isActive});

  final int id;
  final String name;
  final bool isActive;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name, isActive];
}

/// Shartnomadagi kafil. Faqat ko'rsatish uchun kerak bo'lgan maydonlar.
final class ContractGuarantor extends Equatable {
  const ContractGuarantor({
    required this.rowId,
    required this.participantId,
    required this.fullName,
    required this.passport,
    required this.inps,
    required this.workplaceCategoryId,
    required this.underwriterTypes,
    required this.instrumentTypes,
  });

  /// `contract_guarantors.id` — o'chirish shu id bilan ishlaydi.
  final int rowId;

  /// `clients.id` — anderrayter, instrument va yuz tekshiruvi API'lari shuni
  /// kutadi. Kafil yozuvida u `client_id` da keladi; kelmasa `id` ning o'zi
  /// mijoz id si bo'ladi.
  final int participantId;

  final String fullName;
  final String passport;
  final String inps;

  /// Guvohnoma bo'limi ochilishi shu toifaga bog'liq — anderrayter ekraniga
  /// uzatiladi.
  final int workplaceCategoryId;

  /// Serverdan kelgan kodlar (`salary`, `pension`, …).
  final List<String> underwriterTypes;

  /// Serverdan kelgan kodlar (`norasmiy`, `avto`, `p2p`).
  final List<String> instrumentTypes;

  @override
  List<Object?> get props => [
    rowId,
    participantId,
    fullName,
    passport,
    inps,
    workplaceCategoryId,
    underwriterTypes,
    instrumentTypes,
  ];
}

/// Filial rahbari bonusi — shartnomaga biriktirilgan limit.
///
/// Maydonlar backendning `benefit` obyektidan: `required_amount`,
/// `available_amount`, `used_amount`. Bu summalar bonus berilganini emas,
/// undan qancha foydalanish mumkinligini bildiradi.
final class ContractBenefit extends Equatable {
  const ContractBenefit({
    required this.contractId,
    required this.requiredAmount,
    required this.availableAmount,
    required this.usedAmount,
  });

  final int contractId;

  /// Shartnoma uchun talab qilinayotgan summa.
  final int requiredAmount;

  /// Rahbarda qolgan limit — kiritilgan summa shundan oshmaydi.
  final int availableAmount;

  final int usedAmount;

  @override
  List<Object?> get props => [contractId, requiredAmount, availableAmount, usedAmount];
}

/// `GET loans/{id}` javobi — shartnomaning to'liq holati.
final class ContractDetails extends Equatable {
  const ContractDetails({
    required this.id,
    required this.statusCode,
    required this.clientName,
    required this.clientPassport,
    required this.clientInps,
    required this.termMonths,
    required this.paymentDay,
    required this.isFormal,
    required this.hasCarIncome,
    required this.fileUrl,
    required this.products,
    required this.guarantors,
    required this.card,
    required this.tariff,
    required this.benefit,
    required this.mibFailReason,
    required this.katmFailReason,
    required this.workplaceCategoryId,
  });

  final int id;
  /// `null` — server statusni bermadi. Nol bilan almashtirilmaydi: nol
  /// qonuniy status kodi emas va u qoralamani «tahrirlangan» qilib
  /// ko'rsatardi.
  final int? statusCode;
  final String clientName;
  final String clientPassport;
  final String clientInps;
  final int termMonths;

  /// Oyning kuni. Serverdagi ruxsat etilgan kunlar ro'yxatidan tanlanadi.
  final int paymentDay;

  final bool isFormal;
  final bool hasCarIncome;

  /// Shartnoma hujjati. Bo'sh bo'lishi mumkin — hali tayyorlanmagan.
  final String fileUrl;

  final List<ContractProduct> products;
  final List<ContractGuarantor> guarantors;
  final ContractCard card;
  final AppliedTariff tariff;
  final ContractBenefit? benefit;

  /// Skoring rad etilgan bo'lsa sababi. Bo'sh bo'lishi mumkin.
  final String mibFailReason;
  final String katmFailReason;

  /// Anderrayter ekrani qaysi tab to'plamini ko'rsatishini shu belgilaydi.
  final int workplaceCategoryId;

  int get total => products.fold(0, (int sum, ContractProduct item) => sum + item.total);

  bool get hasFile => fileUrl.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    statusCode,
    clientName,
    termMonths,
    paymentDay,
    isFormal,
    hasCarIncome,
    fileUrl,
    products,
    guarantors,
    card,
    tariff,
    benefit,
    mibFailReason,
    katmFailReason,
    workplaceCategoryId,
  ];
}
