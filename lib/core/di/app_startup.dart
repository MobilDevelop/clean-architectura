import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/firebase_service.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AppStartup {
  Future<Result<String>> prepare();
}

final class AppStartupImpl implements AppStartup {
  const AppStartupImpl(this._firebase);

  final FirebaseService _firebase;

  @override
Future<Result<String>> prepare() async {
  try {
    await AppTheme.init();
    ScreenSize.setSizes();
    await _firebase.initialize();

    final info = await PackageInfo.fromPlatform();

    return Ok(info.version);
  } catch (_) {
    return const Err(UnknownFailure('Ilovani ishga tushirib bo\'lmadi'));
  }
}
}
