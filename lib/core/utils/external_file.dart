import 'package:url_launcher/url_launcher.dart';

/// Faylni yoki havolani tashqi ilovada ochish.
///
/// Nega `core/` da: shartnoma tafsiloti ham, fakturalar ham bir xil ish
/// qiladi (1.2). Nega natija qaytaradi: ochadigan ilova bo'lmasa bosish
/// jimgina yo'qolardi — sababni ekran ko'rsatadi (5.8).
abstract final class ExternalFile {
  static Future<bool> open(String url) async {
    final Uri? uri = Uri.tryParse(url);

    if (uri == null || url.isEmpty) return false;

    // `launchUrl` platformadan istisno otadi (masalan manzil sxemasi
    // qo'llab-quvvatlanmasa). Bu `Result` tizimidan tashqaridagi platforma
    // chaqirig'i, shuning uchun u shu yerda ushlanadi — kamera chaqirig'i
    // bilan bir xil qoida.
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
