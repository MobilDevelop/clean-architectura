import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';

abstract final class InstrumentsText {
  static const String title = "Instrumentlar";
  static const String subtitle = "Kafilning daromad manbalari — bir nechtasini tanlash mumkin";
  static const String save = "Saqlash";
  static const String empty = "---";

  static String of(InstrumentType type) => switch (type) {
    InstrumentType.informal => "Norasmiy daromad",
    InstrumentType.car => "Avto daromadi",
    InstrumentType.p2p => "Karta aylanmasi (P2P)",
  };

  /// Kartadagi qisqa nom — to'liq nom qatorga sig'maydi.
  static String short(InstrumentType type) => switch (type) {
    InstrumentType.informal => "Norasmiy",
    InstrumentType.car => "Avto",
    InstrumentType.p2p => "P2P",
  };

  /// Serverdan kelgan kodlar bo'yicha. Tanilmagan kod o'zi ko'rinadi —
  /// yashirilsa xodim instrument yo'q deb o'ylardi.
  static String list(List<String> codes) => codes.map(_label).join(' · ');

  static String _label(String code) {
    final InstrumentType? type = InstrumentType.fromCode(code);

    return type == null ? code : short(type);
  }

  static String conflict(InstrumentType type) => "«${of(type)}» yoqilgan — ikkalasidan birini tanlang";

  static String? card(InstrumentIssue issue) => switch (issue) {
    InstrumentIssue.cardNumberShort => "Karta raqami to'liq kiritilmadi",
    _ => null,
  };

  static String? expiry(InstrumentIssue issue) => switch (issue) {
    InstrumentIssue.expiryInvalid => "Karta muddati yaroqsiz",
    _ => null,
  };

  static String? phone(InstrumentIssue issue) => switch (issue) {
    InstrumentIssue.phoneShort => "Telefon raqami to'liq kiritilmadi",
    _ => null,
  };
}
