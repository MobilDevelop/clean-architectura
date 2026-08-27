import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  const SecureTokenStorage(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveToken(String token) async => await _storage.write(key: 'appUserToken', value: token);
  Future<String> getToken() async => await _storage.read(key: 'appUserToken') ?? '';
  Future<void> deleteToken() async =>  await _storage.delete(key: 'appUserToken');
}