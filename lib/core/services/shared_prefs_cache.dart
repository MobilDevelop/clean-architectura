import 'package:colloborator_v3/core/services/local_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `SharedPreferences` ustidagi muddatli kesh.
///
/// Nega `SecureTokenStorage` emas: Keychain har o'qishda shifrni ochadi va
/// bir necha ming qatorli ro'yxat uchun sekin. Bu yerda saqlanadigan narsa
/// maxfiy emas — viloyat va tuman nomlari.
final class SharedPrefsCache implements LocalCache {
  const SharedPrefsCache({required this._prefs, required this._now});

  final SharedPreferences _prefs;

  /// Vaqt tashqaridan beriladi, aks holda muddat qoidasini test qilib
  /// bo'lmaydi (9.4).
  final DateTime Function() _now;

  static const String _prefix = 'cache.';
  static const String _timeSuffix = '.at';

  @override
  Future<String?> read({required String key, required Duration maxAge}) async {
    final String? value = _prefs.getString('$_prefix$key');
    final int? savedAt = _prefs.getInt('$_prefix$key$_timeSuffix');

    if (value == null || savedAt == null) return null;

    final DateTime saved = DateTime.fromMillisecondsSinceEpoch(savedAt);

    // Kelajakdagi vaqt — qurilma soati orqaga surilgan. Bunday yozuvga
    // ishonmaymiz, yo'qsa u abadiy "yangi" bo'lib qoladi.
    if (saved.isAfter(_now()) || _now().difference(saved) > maxAge) {
      await remove(key);
      return null;
    }

    return value;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    await _prefs.setString('$_prefix$key', value);
    await _prefs.setInt('$_prefix$key$_timeSuffix', _now().millisecondsSinceEpoch);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove('$_prefix$key');
    await _prefs.remove('$_prefix$key$_timeSuffix');
  }

  @override
  Future<void> clear() async {
    final Iterable<String> keys = _prefs.getKeys().where((String key) => key.startsWith(_prefix));

    for (final String key in keys) {
      await _prefs.remove(key);
    }
  }
}
