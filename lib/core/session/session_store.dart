import 'package:colloborator_v3/core/session/app_user.dart';

/// Tizimga kirgan hodim haqidagi ma'lumot.
///
/// Nega `core/` da: hodimning ruxsatlari bir necha featurega kerak — KATM
/// tugmasi shartnomalarda, prescoring menyuda, yetkazib beruvchi esa shartnoma
/// tuzishda. Uni login featurei ichida qoldirsak, boshqalar o'sha featureni
/// import qilishga majbur bo'lardi (1.3).
///
/// Diskda saqlanmaydi: token bilan birga yashaydi va ilova qayta ochilganda
/// yangisi olinadi. Eski nusxa qolib ketsa, ruxsatlar bekor qilingandan keyin
/// ham amal qilib turardi.
abstract interface class SessionStore {
  User? get user;

  void save(User value);

  void clear();
}

final class MemorySessionStore implements SessionStore {
  User? _user;

  @override
  User? get user => _user;

  @override
  void save(User value) => _user = value;

  @override
  void clear() => _user = null;
}
