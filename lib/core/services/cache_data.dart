import 'package:shared_preferences/shared_preferences.dart';

class CacheData {
  static SharedPreferences? prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> putWithExpiry({required String key, required String json}) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs!.setString('${key}_data', json);
    await prefs!.setInt('${key}_time', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<String?> getWithExpiry({required String key, required Duration expiry}) async {
    prefs ??= await SharedPreferences.getInstance();
    final data = prefs!.getString('${key}_data');
    final savedTime = prefs!.getInt('${key}_time');

    if (data == null || savedTime == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;

    if (now - savedTime > expiry.inMilliseconds) {
      await prefs!.remove('${key}_data');
      await prefs!.remove('${key}_time');
      return null;
    }

    return data;
  }

  static Future<void> clear(String key) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs!.remove('${key}_data');
    await prefs!.remove('${key}_time');
  }

  static Future<void> clearAll() async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs!.clear();
  }
}
