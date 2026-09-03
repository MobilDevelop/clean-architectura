import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_text.dart';
import 'package:colloborator_v3/core/router/coordinator.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/widgets/buttons/chuck_button.dart';
import 'package:colloborator_v3/features/splash/presentation/bloc/app_manager_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; 
import 'package:easy_localization/easy_localization.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

final class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppManagerCubit, AppManagerState>(
        builder: (context, state) {
      switch (state) {
      case AppManagerLoading(): return _buildLoadingWidget();
      case AppManagerError(:final failure): return _buildErrorWidget(failure);
      case AppManagerInitial(:final version): return _buildInitialWidget(context, version);
      }
    });
  }

  /// Startup yiqilgandagi ekran.
  ///
  /// Nega bu yerda `AppTheme` ishlatilmaydi: tema `AppStartup.prepare()` ning
  /// birinchi qadamida quriladi. Aynan o'sha yerda yiqilsa, `AppTheme.colors`
  /// hali tayinlanmagan bo'ladi va unga murojaat qilish yana bir istisno
  /// beradi — foydalanuvchi esa bo'sh ekran ko'radi.
  Widget _buildErrorWidget(Failure failure) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ilovani ishga tushirib bo'lmadi",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                FailureText.of(failure),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildLoadingWidget() => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(backgroundColor: Colors.white, body: Center(child: CircularProgressIndicator())),
  );

  Widget _buildInitialWidget(BuildContext context,String version)=>OverlaySupport(
    child: ChangeNotifierProvider<AuthNotifier>.value(
      value: getIt<AuthNotifier>(),
      child: MaterialApp.router(
        title: 'Collaborator Flex',
        theme: AppTheme.data,
        themeMode: AppTheme.themeMode,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        routerConfig: getIt<AppRouter>().router,
        builder: (context, child) => Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => child ?? const SizedBox()),
            //OverlayEntry(builder: (context) => AppVersionWatermark(version: version)),
            if (AppConstants.isStaging) OverlayEntry(builder: (context) => const ChuckButton()),
            //OverlayEntry(builder: (context) => const DotWidget()),
          ], 
        ),
      ),
    ),
  );
}
