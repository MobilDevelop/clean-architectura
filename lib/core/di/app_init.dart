
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:colloborator_v3/core/services/firebase_options.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:colloborator_v3/core/session/session_store.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/auth/login/domain/usecase/restore_session_usecase.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ScreenUtil.ensureScreenSize();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  setupDependencies(await SharedPreferences.getInstance());
  _registerErrorHandlers();

  // Nega DI dan keyin: bildirishnoma bosilganini `PushNotifications` ga
  // uzatadi, ya'ni bog'liqligi bor (8.1). Ilgari u statik singleton edi va
  // shuning uchun DI dan oldin ishga tushirilardi.
  await getIt<LocalNotificationService>().init();

  await getIt<AuthNotifier>().load();

  // Faqat token tiklanadi (yuqorida) — profil (ism, ruxsatlar) alohida,
  // tarmoqsiz tiklanadi. Aks holda `SessionStore.user` `null` bo'lib qolib,
  // drawer sarlavhasi va ruxsatga bog'liq bo'limlar ("Mijoz tahlili" kabi)
  // ilova qayta ochilganda yo'qolib qolardi.
  final Result<User?> restored = await getIt<RestoreSessionUsecase>()(const NoParams());

  switch (restored) {
    case Ok(:final User? value):
      if (value != null) getIt<SessionStore>().save(value);
    case Err():
    // Sababi botga ketgan (5.7) — xodim baribir qayta login qila oladi.
  }
}

/// Ilovaning `Result` tizimidan tashqarida qolgan xatolarni botga uzatadi.
///
/// Nega bu yerda: `getIt` faqat DI qatlamida chaqiriladi (8.2). `main.dart`
/// esa faqat zonani o'rab turadi va xabar berishni shu funksiyalarga topshiradi.
void _registerErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    // Standart ko'rinish saqlanadi: debug'da qizil ekran va konsol xabari.
    FlutterError.presentError(details);

    getIt<ErrorReporter>().report(
      ErrorReport(
        source: 'FlutterError',
        message: details.exception.toString(),
        trace: details.stack,
      ),
    );
  };
}

/// `runZonedGuarded` ushlagan xato. `main.dart` shu funksiyani chaqiradi.
void reportZoneError(Object error, StackTrace stack) => getIt<ErrorReporter>().report(
      ErrorReport(source: 'Unhandled', message: error.toString(), trace: stack),
    );


    