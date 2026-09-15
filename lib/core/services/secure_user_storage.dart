import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Foydalanuvchi profilining xom JSON'ini tokenning yonida saqlaydi.
///
/// Nega kerak: `SessionStore` diskda saqlanmaydi va ilova qayta ochilganda
/// faqat token o'qilardi (`AuthNotifier`) — profil (ism, ruxsatlar) hech
/// qayerda tiklanmasdi, drawer sarlavhasi va ruxsatga bog'liq bo'limlar
/// (masalan "Mijoz tahlili") `null` foydalanuvchi bilan yo'qolib qolardi.
///
/// Shakl bilan ishlamaydi — bu xolis saqlash: `user` obyektining aynan
/// backenddan kelgan ko'rinishi saqlanadi, `AuthRepositoryImpl` uni
/// `UserDto.fromJson` bilan qayta o'qiydi. Shu sababli bu yerda `toJson`
/// qayta yozilmaydi — ikkita joyda bir xil shaklni saqlash xavfi yo'q.
final class SecureUserStorage {
  const SecureUserStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _key = 'appUserProfile';

  Future<void> save(String json) => _storage.write(key: _key, value: json);

  Future<String?> read() => _storage.read(key: _key);

  Future<void> delete() => _storage.delete(key: _key);
}
