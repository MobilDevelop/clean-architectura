import 'package:colloborator_v3/core/services/shared_prefs_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  DateTime now = DateTime(2026, 9, 2, 12);

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 9, 2, 12);
  });

  SharedPrefsCache cache() => SharedPrefsCache(prefs: prefs, now: () => now);

  test('yozilgan qiymat qaytadi', () async {
    await cache().write(key: 'provinces', value: '[1,2]');
    expect(await cache().read(key: 'provinces', maxAge: const Duration(hours: 24)), '[1,2]');
  });

  test('yo‘q kalit uchun null', () async {
    expect(await cache().read(key: 'yoq', maxAge: const Duration(hours: 24)), isNull);
  });

  test('muddati o‘tgan qiymat qaytmaydi', () async {
    await cache().write(key: 'provinces', value: '[1,2]');
    now = now.add(const Duration(hours: 25));

    expect(await cache().read(key: 'provinces', maxAge: const Duration(hours: 24)), isNull);
  });

  test('muddati o‘tgan qiymat o‘chiriladi', () async {
    await cache().write(key: 'provinces', value: '[1,2]');
    now = now.add(const Duration(hours: 25));
    await cache().read(key: 'provinces', maxAge: const Duration(hours: 24));

    expect(prefs.getString('cache.provinces'), isNull);
  });

  // Qurilma soati orqaga surilsa yozuv abadiy "yangi" bo'lib qolmasligi kerak.
  test('kelajakdagi vaqtga ishonilmaydi', () async {
    await cache().write(key: 'provinces', value: '[1,2]');
    now = now.subtract(const Duration(hours: 5));

    expect(await cache().read(key: 'provinces', maxAge: const Duration(hours: 24)), isNull);
  });

  test('clear faqat kesh kalitlarini o‘chiradi', () async {
    await prefs.setString('appUserToken', 'abc');
    await cache().write(key: 'provinces', value: '[1,2]');
    await cache().clear();

    expect(prefs.getString('appUserToken'), 'abc');
    expect(prefs.getString('cache.provinces'), isNull);
  });
}
