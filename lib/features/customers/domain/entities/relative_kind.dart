/// Qarindosh telefoni kimga tegishli ekani.
///
/// [title] — backend kutadigan qiymat, shuning uchun u shartnomaning bir qismi.
/// Ekranda ko'rsatiladigan matn tarjima qilinganda ham [title] o'zgarmaydi.
enum RelativeKind {
  father("Otasi"),
  mother("Onasi"),
  brother("Akasi"),
  sister("Opasi"),
  youngerBrother("Ukasi"),
  youngerSister("Singlisi"),
  spouse("Turmush o'rtog'i"),
  daughter("Qizi"),
  son("O'g'li"),
  relative("Yaqin qarindoshi");

  const RelativeKind(this.title);

  final String title;

  /// Serverdan kelgan matnni turga qaytaradi. Notanish matn — `null`.
  static RelativeKind? fromTitle(String value) {
    for (final RelativeKind kind in RelativeKind.values) {
      if (kind.title == value) return kind;
    }

    return null;
  }
}
