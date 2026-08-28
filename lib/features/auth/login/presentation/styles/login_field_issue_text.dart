import 'package:colloborator_v3/features/auth/login/presentation/bloc/login_state.dart';

/// Kirish maydoni xatosining foydalanuvchiga ko'rinadigan matni.
///
/// Nega presentationda: bloc maydon **bo'sh** ekanini biladi, lekin bu haqda
/// nima deyishni bilmaydi (6.3).
abstract final class LoginFieldIssueText {
  /// `null` — ko'rsatiladigan xato yo'q.
  static String? of(LoginFieldIssue issue, {required String fieldName}) => switch (issue) {
    LoginFieldIssue.none => null,
    LoginFieldIssue.empty => "$fieldName kiritilmadi",
  };
}
