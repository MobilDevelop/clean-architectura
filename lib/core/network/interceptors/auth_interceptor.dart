import 'dart:async';

import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:dio/dio.dart';

// So'rovga token qo'shadi va 401 kelganda sessiyani yopadi.
// UI ko'rsatmaydi va log yozmaydi — bu presentation qatlamining ishi.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._auth);

  final AuthNotifier _auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_auth.isAuthenticated) options.headers['Authorization'] = 'Bearer ${_auth.token}';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Faqat tokenli so'rov rad etilganda chiqaramiz — login so'rovining o'zi
    // 401 qaytarsa (parol xato), bu sessiya tugagani emas
    if (err.response?.statusCode == 401 && _auth.isAuthenticated) unawaited(_auth.signOut());

    handler.next(err);
  }
}