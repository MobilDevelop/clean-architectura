import 'package:colloborator_v3/core/utils/card_expiry.dart';
import 'package:colloborator_v3/core/utils/uz_phone.dart';
import 'package:equatable/equatable.dart';

/// Kafilning daromad manbasi. Bir nechtasi birga bo'lishi mumkin.
enum InstrumentType {
  informal('norasmiy'),
  car('avto'),
  p2p('p2p');

  const InstrumentType(this.code);

  /// Serverga shu satr bilan ketadi.
  final String code;

  static InstrumentType? fromCode(String code) {
    for (final InstrumentType type in InstrumentType.values) {
      if (type.code == code) return type;
    }

    return null;
  }
}

enum InstrumentIssue { none, cardNumberShort, expiryInvalid, phoneShort }

/// Serverda saqlangan karta — faqat ko'rsatish uchun. To'liq raqam qaytmaydi.
final class InstrumentCardInfo extends Equatable {
  const InstrumentCardInfo({required this.mask, required this.expire, required this.phone});

  final String mask;
  final String expire;
  final String phone;

  @override
  List<Object?> get props => <Object?>[mask, expire, phone];
}

/// Xodim kiritayotgan karta. `p2p` yoqilganda to'liq to'ldirilishi shart.
final class InstrumentCardDraft extends Equatable {
  const InstrumentCardDraft({this.number = '', this.expiry = '', this.phone = ''});

  static const int numberLength = 16;

  /// Faqat raqamlar, 16 xona.
  final String number;

  /// `MM/YY`.
  final String expiry;

  /// Faqat raqamlar, 12 xona.
  final String phone;

  bool get isUntouched => number.isEmpty && expiry.isEmpty && phone.isEmpty;

  int get month => int.tryParse(expiry.length >= 2 ? expiry.substring(0, 2) : '') ?? 0;

  int get year => int.tryParse(expiry.length >= 5 ? expiry.substring(3, 5) : '') ?? 0;

  InstrumentIssue issueAt(DateTime now) {
    if (number.length != numberLength) return InstrumentIssue.cardNumberShort;
    if (!CardExpiry.isUsable(month: month, year: year, now: now)) return InstrumentIssue.expiryInvalid;
    if (!UzPhone.isValid(phone)) return InstrumentIssue.phoneShort;

    return InstrumentIssue.none;
  }

  InstrumentCardDraft copyWith({String? number, String? expiry, String? phone}) => InstrumentCardDraft(
    number: number ?? this.number,
    expiry: expiry ?? this.expiry,
    phone: phone ?? this.phone,
  );

  @override
  List<Object?> get props => <Object?>[number, expiry, phone];
}

/// Kafilning instrumentlari — serverdagi holat va uning qoidalari.
final class GuarantorInstruments extends Equatable {
  const GuarantorInstruments({
    required this.types,
    required this.card,
    required this.exclusive,
    this.unknown = const <String>{},
  });

  const GuarantorInstruments.empty()
    : types = const <InstrumentType>{},
      card = null,
      exclusive = const <Set<InstrumentType>>{},
      unknown = const <String>{};

  final Set<InstrumentType> types;

  /// Ilova tanimaydigan turlar. Saqlashda o'zgarmasdan qaytariladi: `PUT`
  /// to'liq almashtirgani uchun ularni tushirib qoldirish serverdagi
  /// instrumentni jimgina o'chirib yuborardi.
  final Set<String> unknown;

  /// `p2p` yoqilgan bo'lsa serverdagi karta.
  final InstrumentCardInfo? card;

  /// Birga tanlanmaydigan juftliklar. Qoida serverdan keladi — ilovaga
  /// qattiq yozilmaydi, backend o'zgartirsa o'zi kelib turadi.
  final Set<Set<InstrumentType>> exclusive;

  /// `type` ni yoqish `selected` dagi qaysi instrument bilan ziddiyat
  /// keltiradi. `null` — ziddiyat yo'q.
  InstrumentType? conflictOf(InstrumentType type, Set<InstrumentType> selected) {
    for (final Set<InstrumentType> pair in exclusive) {
      if (!pair.contains(type)) continue;

      for (final InstrumentType other in pair) {
        if (other != type && selected.contains(other)) return other;
      }
    }

    return null;
  }

  @override
  List<Object?> get props => <Object?>[types, card, exclusive, unknown];
}

/// Saqlash so'rovi. `PUT` to'liq almashtiradi: ro'yxatda yo'q instrument
/// o'chiriladi, shuning uchun har safar to'liq to'plam yuboriladi.
final class SaveInstrumentsParams extends Equatable {
  const SaveInstrumentsParams({
    required this.contractId,
    required this.clientId,
    required this.types,
    required this.card,
    this.unknown = const <String>{},
  });

  final int contractId;

  /// Kafilning `clients.id` si — `contract_guarantors.id` **emas**.
  final int clientId;

  final Set<InstrumentType> types;

  /// Faqat `p2p` yoqilgan va karta yangi kiritilgan bo'lsa yuboriladi.
  final InstrumentCardDraft? card;

  /// O'zgarmasdan qaytariladigan, ilova tanimagan turlar.
  final Set<String> unknown;

  /// Serverga ketadigan to'liq to'plam.
  List<String> get codes => <String>[...types.map((InstrumentType e) => e.code), ...unknown];

  @override
  List<Object?> get props => <Object?>[contractId, clientId, types, card, unknown];
}

/// O'qish so'rovi.
final class GuarantorRef extends Equatable {
  const GuarantorRef({required this.contractId, required this.clientId});

  final int contractId;
  final int clientId;

  @override
  List<Object?> get props => <Object?>[contractId, clientId];
}
