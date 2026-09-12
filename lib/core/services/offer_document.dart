import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:flutter/services.dart';

/// Ommaviy oferta matni — bir marta o'qiladi.
///
/// Nega kesh kerak. `rootBundle` ham keshlaydi (o'lchandi: birinchi o'qish
/// 14.6 ms, keyingisi 0.3 ms), lekin natijani baribir `Future` qilib
/// qaytaradi. Ya'ni oyna har ochilganda kamida bitta kadr yuklanish belgisi
/// bilan chiziladi — foydalanuvchi aynan shuni ko'radi, ish uzoq davom
/// etganidan emas. Bu yerda saqlangan matn **sinxron** olinadi va belgi
/// umuman ko'rinmaydi.
///
/// Nega `core/` da: uni ilova ishga tushganda `AppStartup` oldindan o'qiydi.
///
/// Kalit bo'yicha saqlanadi: `assets/offer/` da o'zbekcha va ruscha fayllar
/// bor, tilga qarab tanlash lokalizatsiya bilan birga qo'shiladi.
final class OfferDocument {
  OfferDocument(this._bundle);

  final AssetBundle _bundle;

  final Map<String, String> _texts = <String, String>{};

  /// O'qilgan bo'lsa darhol qaytaradi. `null` — hali o'qilmagan.
  String? ready(String asset) => _texts[asset];

  /// Nega `Result`: aks holda chaqiruvchi oyna uni `try/catch` bilan o'rashga
  /// majbur bo'lardi, bu esa 12-bo'limga ko'ra «chaqiruv `Result` tizimidan
  /// tashqarida qolgan» degan belgi. Fayl topilmasligi — bizning nosozligimiz,
  /// shuning uchun `guard` uni botga ham yuboradi (5.7).
  Future<Result<String>> load(String asset) => guard(() async {
    final String? text = _texts[asset];
    if (text != null) return text;

    final String value = await _bundle.loadString(asset);
    _texts[asset] = value;

    return value;
  });

  /// Ishga tushishda oldindan o'qish.
  ///
  /// Natija e'tiborsiz qoldiriladi va bu jimgina yiqilish emas (5.8): oferta
  /// ilovaning ishga tushishiga to'sqinlik qilmaydi, oynaning o'zi esa qayta
  /// o'qiydi va muvaffaqiyatsiz bo'lsa «Hujjat ochilmadi» + «Qayta urinish»
  /// ko'rsatadi. Sabab `guard` orqali botga allaqachon ketgan.
  Future<void> warmUp(String asset) async {
    await load(asset);
  }
}
