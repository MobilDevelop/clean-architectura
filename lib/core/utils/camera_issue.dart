import 'package:flutter/services.dart';

/// Kamera ochilmaganining sababi.
///
/// Kamera chaqirig'i sahifada turadi (6.2), shuning uchun uning nosozligi ham
/// shu qatlamda tasniflanadi — bu server xatosi emas va `Failure` ga
/// aylantirilmaydi (5.2: turlar "kim aybdor va foydalanuvchi nima qilishi
/// kerak" bo'yicha ajratiladi).
enum CameraIssue { none, denied, unavailable, busy, unknown }

abstract final class CameraIssues {
  /// `image_picker` xatosini sababga aylantiradi.
  ///
  /// Kodlar `image_picker` ning platforma qismidan keladi va faqat shu yerda
  /// o'qiladi. Ikki platforma ikki xil to'plam beradi:
  ///
  /// | Kod | Android | iOS |
  /// |---|---|---|
  /// | `camera_access_denied` | ha | ha |
  /// | `photo_access_denied` | — | ha |
  /// | `no_available_camera` | ha | — |
  /// | `already_active` | ha | — |
  /// | `multiple_request` | — | ha |
  ///
  /// `multiple_request` ilgari qamrab olinmagan edi va iOS'da «oldingi so'rov
  /// hali tugamagan» holati «Kamerani ochib bo'lmadi» degan noto'g'ri xabar
  /// bilan chiqardi.
  ///
  /// iOS'da kamera umuman yo'q bo'lsa (simulyator) `image_picker` istisno
  /// otmaydi: o'zining «Camera not available» oynasini ko'rsatib, natijani
  /// `null` qilib qaytaradi — ya'ni bu yo'l bekor qilish bilan bir xil
  /// ko'rinadi va sabab foydalanuvchiga plaginning o'zi tomonidan aytiladi.
  static CameraIssue of(PlatformException error) => switch (error.code) {
    'camera_access_denied' || 'photo_access_denied' => CameraIssue.denied,
    'no_available_camera' => CameraIssue.unavailable,
    'already_active' || 'multiple_request' => CameraIssue.busy,
    _ => CameraIssue.unknown,
  };
}

/// Sababning ekran matni. Matn sahifa qatlamida — domain uni yaratmaydi (3.9).
abstract final class CameraIssueText {
  static String? of(CameraIssue issue) => switch (issue) {
    CameraIssue.none => null,
    CameraIssue.denied => "Kameraga ruxsat berilmagan. Sozlamalardan ruxsat bering",
    CameraIssue.unavailable => "Bu qurilmada kamera topilmadi",
    CameraIssue.busy => "Kamera hali ochilmoqda — biroz kuting",
    CameraIssue.unknown => "Kamerani ochib bo'lmadi. Qaytadan urinib ko'ring",
  };
}
