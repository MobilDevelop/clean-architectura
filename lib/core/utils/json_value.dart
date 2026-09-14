/// Javobdagi bitta qiymatni kutilgan tipga keltirish.
///
/// Nega `core/` da: bir xil to'rtta yordamchi beshta DTO faylida so'zma-so'z
/// takrorlanardi (1.2). Takrorlangan nusxada bittasi tuzatilsa qolganlari
/// eski holicha qolib ketardi.
///
/// Nega `num.tryParse`: server bir xil maydonni goh son, goh satr qilib
/// yuboradi (`1800000` va `"1800000.00"`), `int.tryParse` esa kasrli satrda
/// `null` beradi.
abstract final class JsonValue {
  /// O'qib bo'lmasa `0`. Majburiy maydon uchun bu **zaxira qiymat emas**:
  /// nol ekranda ko'rinadi va nosozlik shu bilan bilinadi (4.6).
  static int toInt(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

  /// Qiymat yo'qligi ma'noli bo'lgan maydonlar uchun — `0` bilan
  /// aralashtirib bo'lmaydigan holat.
  static int? toNullableInt(Object? raw) => raw == null ? null : num.tryParse(raw.toString())?.toInt();

  static String toText(Object? raw) => raw?.toString() ?? '';

  /// Faqat raqamlar: telefon va hujjat raqamlari serverdan turli ko'rinishda
  /// keladi (`+998 90 …`, `(90) …`).
  static String toDigits(Object? raw) => raw?.toString().replaceAll(RegExp(r'\D'), '') ?? '';

  /// Majburiy identifikator (`id`, `client_id`): `toInt`dan farqli, yo'qlik
  /// meʼyoriy emas — `0`ga aylantirish boshqa yozuvga ishora qilib qo'yishi
  /// mumkin (4.6). Topilmasa `FormatException`.
  static int requireInt(Object? raw, {required String field}) {
    final int? value = raw == null ? null : num.tryParse(raw.toString())?.toInt();
    if (value == null) throw FormatException('majburiy maydon yo\'q yoki son emas: $field');

    return value;
  }

  /// Kalit yo'q — `fallback`. Kalit bor-u son emas — `FormatException`:
  /// yo'qlik meʼyoriy, buzuq shakl emas (4.6).
  static num numOrDefault(Map<String, dynamic> json, String key, num fallback) {
    final Object? raw = json[key];
    if (raw == null) return fallback;
    if (raw is num) return raw;

    final num? parsed = num.tryParse(raw.toString());
    if (parsed != null) return parsed;

    throw FormatException('"$key" son emas: ${raw.runtimeType}');
  }
}
