import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/auth_session.dart';
import 'package:colloborator_v3/features/auth/login/domain/entities/login_param.dart';

// Auth uchun shartnoma. Domain faqat shuni biladi —
// uni HTTP bajaradimi, keshdan o'qiydimi, soxta obyektmi, ahamiyati yo'q.
abstract interface class AuthRepository {
  Future<Result<AuthSession>> login(LoginParams params);

  Future<Result<void>> logout();

  /// Oldingi kirishda saqlangan profilni tarmoqsiz tiklaydi. Topilmasa yoki
  /// buzuq bo'lsa `null` — bu xato emas, shunchaki qayta login kerak.
  Future<Result<User?>> restoreSession();
}