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

  Future<String> load(String asset) async {
    final String? text = _texts[asset];
    if (text != null) return text;

    final String value = await _bundle.loadString(asset);
    _texts[asset] = value;

    return value;
  }

  /// Ishga tushishda oldindan o'qish.
  ///
  /// Yiqilsa jim qoladi va bu jimgina yiqilish emas (5.8): oferta ilovaning
  /// ishga tushishiga to'sqinlik qilmaydi, oynaning o'zi esa qayta o'qiydi va
  /// muvaffaqiyatsiz bo'lsa «Hujjat ochilmadi» + «Qayta urinish» ko'rsatadi.
  Future<void> warmUp(String asset) async {
    try {
      await load(asset);
    } catch (_) {
      // Sabab shu yerda emas, oynada ko'rsatiladi.
    }
  }
}
