/// Kamdan-kam o'zgaradigan ma'lumotni diskda saqlaydi.
///
/// Shartnoma `core/` da: viloyat ro'yxatlari, sozlamalar va boshqa
/// ma'lumotnomalar bir necha featurega kerak bo'ladi.
abstract interface class LocalCache {
  /// Yozilganiga [maxAge] dan ko'p vaqt o'tgan bo'lsa `null` qaytadi —
  /// chaqiruvchi uchun bu keshda yo'q degani.
  Future<String?> read({required String key, required Duration maxAge});

  Future<void> write({required String key, required String value});

  Future<void> remove(String key);

  /// Chiqishda chaqiriladi: bir agentning ma'lumoti ikkinchisiga ko'rinmasin.
  Future<void> clear();
}
