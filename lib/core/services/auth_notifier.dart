import 'package:colloborator_v3/core/services/secure_token_storage.dart';
import 'package:flutter/foundation.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._tokenStorage);

  final SecureTokenStorage _tokenStorage;

  String _token = '';
  String get token => _token;

  bool get isAuthenticated => _token.isNotEmpty;

  /// Startupda bir marta: tokenni diskdan xotiraga o'qiydi.
  Future<void> load() async {
    _token = await _tokenStorage.getToken();
    notifyListeners();
  }

  Future<void> signIn(String token) async {
    await _tokenStorage.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _tokenStorage.deleteToken();
    _token = '';
    notifyListeners();
  }
}