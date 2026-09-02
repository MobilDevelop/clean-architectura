
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/services/error_reporter.dart';
import 'package:colloborator_v3/core/services/firebase_options.dart';
import 'package:colloborator_v3/core/services/notification_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await ScreenUtil.ensureScreenSize();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalNotificationService.instance.init();

  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  setupDependencies();
  _registerErrorHandlers();

  await getIt<AuthNotifier>().load();
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


    