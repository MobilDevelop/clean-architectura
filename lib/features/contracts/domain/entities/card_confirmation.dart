import 'package:equatable/equatable.dart';

/// ELMA oqimining bosqichi. Backend uni `state` satri bilan yuboradi.
///
/// Nega enum: satrning o'zi (`"1"`, `"2"`, `"4"`) hech nima aytmaydi va u
/// ekranda to'rt joyda solishtirilardi. Noma'lum qiymat OTP deb qabul
/// qilinadi — flex ham shunday, chunki ELMA yangi kod qo'shishi mumkin.
enum CardConfirmStep {
  /// `2` — kod yuborilmagan yoki muddati tugagan.
  resend,

  /// `4` — karta ma'lumoti to'liq emas, foydalanuvchi kiritishi kerak.
  cardNeeded,

  /// Qolgan hamma holat — kod yuborilgan, OTP kutilmoqda.
  otp;

  static CardConfirmStep fromCode(String code) => switch (code) {
    '2' => CardConfirmStep.resend,
    '4' => CardConfirmStep.cardNeeded,
    _ => CardConfirmStep.otp,
  };
}

/// Serverga yuboriladigan amal — so'rovda `state` bo'lib ketadi.
enum CardConfirmAction {
  /// Kiritilgan OTP kodi bilan tasdiqlash.
  code('1'),

  /// Kodni qayta yuborish.
  resend('2'),

  /// Kartani tekshirmasdan davom etish.
  skipCard('3'),

  /// Kiritilgan karta ma'lumoti bilan davom etish.
  saveCard('4');

  const CardConfirmAction(this.value);

  final String value;
}

/// Kartani tasdiqlash uchun serverdan kelgan holat.
final class CardConfirmation extends Equatable {
  const CardConfirmation({
    required this.contractId,
    required this.cardId,
    required this.elmaApplicationId,
    required this.elmaInstanceId,
    required this.phone,
    required this.message,
    required this.step,
    required this.expiresAt,
    required this.cardNumber,
    required this.cardExpiry,
    required this.isOwnerMismatch,
  });

  final int contractId;
  final int cardId;
  final String elmaApplicationId;
  final String elmaInstanceId;

  /// SMS yuborilgan raqam — faqat raqamlar.
  final String phone;

  /// Serverdan kelgan izoh yoki xato matni. Bo'sh bo'lishi mumkin.
  final String message;

  final CardConfirmStep step;

  /// Kod muddati tugaydigan payt. `null` — server aytmagan.
  final DateTime? expiresAt;

  final String cardNumber;

  /// `MM/YY`.
  final String cardExpiry;

  /// Karta mijozga emas, boshqa shaxsga tegishli — ELMA OTP yubormaydi va
  /// server har qanday davom etishni rad etadi. Yagona yo'l — bekor qilish.
  final bool isOwnerMismatch;

  @override
  List<Object?> get props => <Object?>[
    contractId,
    cardId,
    elmaApplicationId,
    elmaInstanceId,
    phone,
    message,
    step,
    expiresAt,
    cardNumber,
    cardExpiry,
    isOwnerMismatch,
  ];
}

/// Kiritishga to'sqinlik qilayotgan kamchilik.
enum CardConfirmIssue { none, codeMissing, cardNumberShort, expiryInvalid, phoneShort }

/// Foydalanuvchi kiritadigan karta ma'lumoti.
///
/// Nega domainda: backend ham shu qoidalarni tekshiradi (7.3). Flex bu yerda
/// `int.parse(date.substring(0, 2))` qilardi — noto'g'ri kiritilgan sanada u
/// istisno otardi.
final class CardEntry extends Equatable {
  const CardEntry({required this.number, required this.expiry, required this.phone});

  const CardEntry.empty() : number = '', expiry = '', phone = '';

  /// Faqat raqamlar, 16 xona.
  final String number;

  /// `MM/YY`.
  final String expiry;

  /// Faqat raqamlar, 12 xona (`998…`).
  final String phone;

  static const int _numberLength = 16;
  static const int _phoneLength = 12;

  int get month => int.tryParse(expiry.length >= 2 ? expiry.substring(0, 2) : '') ?? 0;

  int get year => int.tryParse(expiry.length >= 5 ? expiry.substring(3, 5) : '') ?? 0;

  CardConfirmIssue get issue {
    if (number.length != _numberLength) return CardConfirmIssue.cardNumberShort;
    if (month < 1 || month > 12 || year == 0) return CardConfirmIssue.expiryInvalid;
    if (phone.length != _phoneLength) return CardConfirmIssue.phoneShort;

    return CardConfirmIssue.none;
  }

  @override
  List<Object?> get props => <Object?>[number, expiry, phone];
}

/// Tasdiqlash so'rovi.
final class CardConfirmParams extends Equatable {
  const CardConfirmParams({
    required this.confirmation,
    required this.action,
    this.code = '',
    this.entry = const CardEntry.empty(),
  });

  final CardConfirmation confirmation;
  final CardConfirmAction action;

  /// OTP kodi — faqat `code` amalida ishlatiladi.
  final String code;

  /// Karta ma'lumoti — faqat `saveCard` amalida ishlatiladi.
  final CardEntry entry;

  @override
  List<Object?> get props => <Object?>[confirmation, action, code, entry];
}
