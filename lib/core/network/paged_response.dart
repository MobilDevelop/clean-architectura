/// Sahifalangan javobni o'qish.
///
/// Nega `core/` da: chiqim tovarlar va fakturalar ro'yxatlari bir xil
/// sahifalashdan foydalanadi (1.2).
abstract final class PagedResponse {
  /// Oxirgi sahifami.
  ///
  /// Server sahifa ma'lumotini bersa unga tayaniladi, aks holda to'lmagan
  /// sahifa oxirgisi deb hisoblanadi. Flex bo'sh javob kelguncha sahifani
  /// oshiraverardi — ya'ni har doim bitta ortiqcha so'rov yuborardi.
  static bool isLast({
    required Map<String, dynamic> json,
    required int received,
    required int page,
    required int perPage,
  }) {
    final Object? lastPage = json['last_page'] ?? json['meta'];
    final int? last = lastPage is Map ? int.tryParse('${lastPage['last_page']}') : int.tryParse('$lastPage');

    if (last != null && last > 0) return page >= last;

    return received < perPage;
  }
}
