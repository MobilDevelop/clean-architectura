import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:dio/dio.dart';

// So'rovga token qo'shadi. Boshqa hech nima qilmaydi.
//
// Nega bu yerda `signOut` yo'q: 401 kelganda sessiyani yopish — ko'rinadigan
// amal, foydalanuvchi nima uchun chiqarilganini bilishi kerak. Uni tarmoq
// qatlami ham, `FailureView` ham bajarsa, interceptor birinchi ulguradi va
// router ekranni yiqitib, dialogni ko'rsatishga ham imkon bermaydi (6.4).
// Sessiyani yopish faqat `FailureView` da — dialog yopilgandan keyin.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._auth);

  final AuthNotifier _auth;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_auth.isAuthenticated) options.headers['Authorization'] = 'Bearer ${_auth.token}';

    handler.next(options);
  }
}