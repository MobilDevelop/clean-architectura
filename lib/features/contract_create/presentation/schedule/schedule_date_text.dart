/// To'lov sanasining ekrandagi ko'rinishi.
///
/// Nega `DateFormat` emas: o'zbekcha oy nomlari uchun `intl` ga alohida
/// lokal ma'lumot yuklash kerak bo'ladi. Bu yerda kerak bo'lgani — o'n ikkita
/// so'z, ular bevosita yozilgani aniqroq va tarjimaga ham tayyor.
abstract final class ScheduleDateText {
  static const List<String> _months = <String>[
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  /// `2026-01-15` → `15-yanvar 2026`. Sana yo'q bo'lsa chiziqcha.
  static String of(DateTime? date) {
    if (date == null) return '—';

    return "${date.day}-${_months[date.month - 1]} ${date.year}";
  }
}
