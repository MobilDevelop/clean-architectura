import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
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

  Future<Result<void>> signIn(String token) async {
    try {
      await _tokenStorage.saveToken(token);
      _token = token;
      notifyListeners();
      return const Ok(null);
    } catch (_) {
      return const Err(UnknownFailure('Kirish ma\'lumotini saqlab bo\'lmadi'));
    }
  }

  Future<void> signOut() async {
  try {
    await _tokenStorage.deleteToken();
  } catch (_) {
    // Diskdan o'chirib bo'lmasa ham, xotiradagi sessiya tugatiladi —
    // aks holda ilova yarim kirgan holatda qolib ketadi.
  }

  _token = '';
  notifyListeners();
}
}