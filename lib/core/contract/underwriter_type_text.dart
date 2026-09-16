/// Anderrayter turi kodini nomga o'giradi.
///
/// Nega `core/` da: kodlar serverdan keladi va ularni ikkita feature
/// ko'rsatadi — anderrayter ekrani va shartnomaning kafillar tabi (1.2).
abstract final class UnderwriterTypeText {
  static String of(String code) => switch (code) {
    'salary' => "Ish haqi",
    'pension' => "Pensiya",
    'military' => "Guvohnoma",
    'student' => "Talaba",
    'car' => "Avtomobil",
    _ => code,
  };

  /// Bo'sh ro'yxatda bo'sh satr — chaqiruvchi o'zi «---» yoki boshqa narsa
  /// ko'rsatishni hal qiladi.
  static String list(List<String> codes) => codes.map(of).join(', ');
}
