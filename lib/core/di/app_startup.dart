import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/app_info.dart';
import 'package:colloborator_v3/core/services/firebase_service.dart';
import 'package:colloborator_v3/core/services/offer_document.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AppStartup {
  Future<Result<void>> prepare();
}

final class AppStartupImpl implements AppStartup {
  const AppStartupImpl(this._firebase, this._offer, this._info);

  final FirebaseService _firebase;
  final OfferDocument _offer;
  final AppInfo _info;

  @override
Future<Result<void>> prepare() async {
  try {
    await AppTheme.init();
    ScreenSize.setSizes();
    await _firebase.initialize();

    // Oferta shu yerda o'qiladi: aks holda oyna har ochilganda bir kadr
    // yuklanish belgisi bilan chiziladi. 26 KB — splash ostida sezilmaydi.
    await _offer.warmUp(AppIcons.offerUz);

    final info = await PackageInfo.fromPlatform();

    // Versiya bir marta o'qiladi va ilova bo'ylab shu yerdan — `AppInfo` dan —
    // olinadi. Uni holatga ham qo'shish ikkinchi manba yaratardi.
    _info.save(info.version);

    return const Ok<void>(null);
  } catch (_) {
    return const Err(UnknownFailure('Ilovani ishga tushirib bo\'lmadi'));
  }
}
}
