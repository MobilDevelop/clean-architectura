import 'package:equatable/equatable.dart';

/// Mavjud tovar qatorini o'zgartirish.
final class UpdateProductParams extends Equatable {
  const UpdateProductParams({
    required this.productId,
    required this.supplierId,
    required this.price,
    required this.count,
  });

  final int productId;
  final int supplierId;

  /// Butun so'mda.
  final int price;

  final int count;

  @override
  List<Object?> get props => [productId, supplierId, price, count];
}

/// Shartnomani skoringga yuborish.
///
/// Tovarlar, kafillar va karta o'z so'rovlari bilan allaqachon saqlangan —
/// bu yerda faqat shartlar ketadi.
final class SubmitContractParams extends Equatable {
  const SubmitContractParams({
    required this.contractId,
    required this.termMonths,
    required this.paymentDay,
    required this.isFormal,
    required this.hasCarIncome,
    required this.occupationTypeId,
    required this.isEdit,
  });

  final int contractId;
  final int termMonths;
  final int paymentDay;
  final bool isFormal;
  final bool hasCarIncome;

  /// Qo'shimcha daromad turi. `0` — server uni so'ramagan va yuborilmaydi.
  final int occupationTypeId;

  /// Mavjud shartnoma — `PUT`, aks holda `POST`.
  ///
  /// Mezon marshrut argumenti emas, shartnoma statusi: qoralama status 1 da
  /// turadi va aynan shu holatda `POST` kutiladi. Status 1 dagi shartnomani
  /// tahrirlash uchun ham ochish mumkin, shuning uchun "tahrirlash rejimi"
  /// bilan aralashtirib bo'lmaydi.
  final bool isEdit;

  @override
  List<Object?> get props => [
    contractId,
    termMonths,
    paymentDay,
    isFormal,
    hasCarIncome,
    occupationTypeId,
    isEdit,
  ];
}
