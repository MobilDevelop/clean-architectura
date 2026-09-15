import 'package:equatable/equatable.dart';

/// Tezkor narx taxmini. Serverga so'rov yubormaydi — hammasi mahalliy hisob.
/// Yakuniy summa shartnoma tuzilganda `generate_graphic` orqali serverda
/// aniqlanadi (bu yerdagi natija faqat taxmin).
final class CreditCalculation extends Equatable {
  const CreditCalculation({
    required this.price,
    required this.termMonths,
    required this.frontMarginPercent,
    required this.backMarginPercent,
  });

  factory CreditCalculation.initial() => const CreditCalculation(
    price: 0,
    termMonths: defaultTermMonths,
    frontMarginPercent: defaultFrontMarginPercent,
    backMarginPercent: defaultBackMarginPercent,
  );

  /// Shartnoma 1 oydan 12 oygacha tuziladi — `ContractForm` dagi muddat
  /// chegarasi bilan bir xil.
  static const int minTermMonths = 1;
  static const int maxTermMonths = 12;
  static const int defaultTermMonths = 8;

  static const int minMarginPercent = 0;
  static const int maxFrontMarginPercent = 20;
  static const int maxBackMarginPercent = 100;
  static const int defaultFrontMarginPercent = 5;
  static const int defaultBackMarginPercent = 15;

  /// Kirim narxi, so'mda.
  final int price;

  final int termMonths;

  /// Faqat butun foiz — chegaradan oshiradigan raqam maydonga kiritilmaydi
  /// (`MaxPercentFormatter`), shuning uchun bu yerda qayta tekshirilmaydi.
  final int frontMarginPercent;
  final int backMarginPercent;

  /// Front ustamali narx: `ceil(price × (100 + front) / 100)`.
  int get sellingPrice => price == 0 ? 0 : (price * (100 + frontMarginPercent) / 100).ceil();

  /// Bek ustamali narx: ustama qismi alohida yaxlitlanadi va sotish
  /// narxiga qo'shiladi.
  int get totalPrice => sellingPrice == 0 ? 0 : (sellingPrice * backMarginPercent / 100).ceil() + sellingPrice;

  /// Oylik to'lov yuqoriga yaxlitlanadi — yaxlitlash ortig'i oxirgi oyda
  /// qaytariladi.
  int get monthlyPayment => totalPrice == 0 ? 0 : (totalPrice / termMonths).ceil();

  /// Oxirgi oy: `monthly + (total − monthly × term)`. `monthly` yuqoriga
  /// yaxlitlangani uchun qavs ichidagi farq musbat bo'lmaydi.
  int get lastMonthPayment => monthlyPayment + (totalPrice - monthlyPayment * termMonths);

  /// Narx kiritilmaguncha jadval qiymat o'rniga chiziqcha ko'rsatadi.
  bool get hasResult => price > 0;

  /// Jami muddatga qoldiqsiz bo'linsa oxirgi oy oylikka teng — ortiqcha
  /// qator chizilmaydi.
  bool get showLastMonthPayment => hasResult && lastMonthPayment != monthlyPayment && lastMonthPayment > 0;

  CreditCalculation copyWith({int? price, int? termMonths, int? frontMarginPercent, int? backMarginPercent}) =>
      CreditCalculation(
        price: price ?? this.price,
        termMonths: termMonths ?? this.termMonths,
        frontMarginPercent: frontMarginPercent ?? this.frontMarginPercent,
        backMarginPercent: backMarginPercent ?? this.backMarginPercent,
      );

  @override
  List<Object?> get props => <Object?>[price, termMonths, frontMarginPercent, backMarginPercent];
}
