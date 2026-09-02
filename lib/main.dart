import 'dart:async';
import 'package:colloborator_v3/core/di/app_init.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/services/firebase_service.dart';
import 'package:colloborator_v3/features/splash/presentation/bloc/app_manager_cubit.dart';
import 'package:colloborator_v3/features/splash/presentation/pages/splash_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 
Future<void> main() async {
  // Nega `runZonedGuarded`: `async` kodda ushlanmagan istisnolar shu yerda
  // to'planadi. `FlutterError.onError` esa widget qurishdagi xatolarni oladi —
  // u `initializeApp()` ichida o'rnatiladi.
  await runZonedGuarded<Future<void>>(() async {
    await initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Dasturni ishga tushirish
    runApp(
      EasyLocalization(
        supportedLocales: const [Locale('uz')],
        useFallbackTranslations: true,
        useOnlyLangCode: true,
        fallbackLocale: const Locale('uz'),
        path: 'assets/translations',
        child: const MyApp(),
      ),
    );
  }, reportZoneError);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<AppManagerCubit>()..init()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ScreenUtilInit(
            designSize: const Size(393, 852),
            minTextAdapt: true,
            splitScreenMode: true,
            useInheritedMediaQuery: true,
            builder: (context, child) => SplashPage(),
          );
        },
      ),
    );
  }
}