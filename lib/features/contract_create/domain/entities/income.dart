import 'package:colloborator_v3/core/utils/card_expiry.dart';
import 'package:colloborator_v3/core/utils/uz_phone.dart';
import 'package:equatable/equatable.dart';

/// Daromad asosi.
///
/// Flex'da bu `isFormal: state.isInformal` ko'rinishida teskari nomlangan
/// bo'lib yurgan. Enum shu chalkashlikni tip darajasida yopadi: `formal` va
/// `informal` ni bir-biriga almashtirib bo'lmaydi.
enum IncomeBasis {
  formal,
  informal;

  /// Serverga `formal` bayrog'i sifatida ketadi.
  bool get isFormal => this == IncomeBasis.formal;

  static IncomeBasis of({required bool isFormal}) => isFormal ? IncomeBasis.formal : IncomeBasis.informal;
}

/// Qo'shimcha daromad turi (`occupation-types`).
final class OccupationType extends Equatable {
  const OccupationType({required this.id, required this.name});

  final int id;
  final String name;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name];
}

/// `occupation-types/get-all-autocomplete` javobi.
///
/// `isRequired` — javobdagi `check` maydoni. Server shu bilan "bu shartnomada
/// kasb turi so'ralsinmi" degan qarorni o'zi beradi; mijoz uni o'zi hisoblamaydi.
final class OccupationCatalog extends Equatable {
  const OccupationCatalog({required this.items, required this.isRequired});

  const OccupationCatalog.empty() : items = const <OccupationType>[], isRequired = false;

  final List<OccupationType> items;
  final bool isRequired;

  @override
  List<Object?> get props => [items, isRequired];
}

/// Plastik karta kiritish formasi.
///
/// Uzunliklar formatlangan matnga emas, RAQAMLARGA nisbatan tekshiriladi:
/// flex `phone != 17` deb formatlangan satrni o'lchagan va formatter
/// o'zgarganda qoida jimgina buzilardi.
enum CardFieldIssue { none, phoneIncomplete, numberIncomplete, expiryIncomplete, expiryInvalid }

final class CardForm extends Equatable {
  const CardForm({this.phone = '', this.number = '', this.expiry = ''});

  static const int phoneDigits = 12;
  static const int numberDigits = 16;
  static const int expiryDigits = 4;

  /// Faqat raqamlar: `+998 90 123-45-67` → `998901234567`.
  final String phone;
  final String number;

  /// `MMYY`.
  final String expiry;

  int get month => expiry.length < 2 ? 0 : int.tryParse(expiry.substring(0, 2)) ?? 0;

  int get year => expiry.length < 4 ? 0 : int.tryParse(expiry.substring(2, 4)) ?? 0;

  /// Vaqt tashqaridan: muddat o'tganini tekshirish uchun bugungi sana kerak,
  /// uni entity ichida o'qish esa qoidani soatga bog'lab qo'yardi (9.4).
  CardFieldIssue issueAt(DateTime now) {
    if (!UzPhone.isValid(phone)) return CardFieldIssue.phoneIncomplete;
    if (number.length != numberDigits) return CardFieldIssue.numberIncomplete;
    if (expiry.length != expiryDigits) return CardFieldIssue.expiryIncomplete;
    if (!CardExpiry.isUsable(month: month, year: year, now: now)) return CardFieldIssue.expiryInvalid;

    return CardFieldIssue.none;
  }

  CardForm copyWith({String? phone, String? number, String? expiry}) =>
      CardForm(phone: phone ?? this.phone, number: number ?? this.number, expiry: expiry ?? this.expiry);

  @override
  List<Object?> get props => [phone, number, expiry];
}

/// `POST add_loan_plastic_card` kirishi.
final class AddCardParams extends Equatable {
  const AddCardParams({required this.contractId, required this.clientId, required this.form});

  final int contractId;
  final int clientId;
  final CardForm form;

  @override
  List<Object?> get props => [contractId, clientId, form];
}

/// `PUT delete_loan_plastic_card/{cardId}` kirishi.
final class RemoveCardParams extends Equatable {
  const RemoveCardParams({required this.cardId, required this.contractId});

  final int cardId;
  final int contractId;

  @override
  List<Object?> get props => [cardId, contractId];
}
