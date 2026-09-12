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
  /// o'qiladi.
  static CameraIssue of(PlatformException error) => switch (error.code) {
    'camera_access_denied' || 'photo_access_denied' => CameraIssue.denied,
    'no_available_camera' => CameraIssue.unavailable,
    'already_active' => CameraIssue.busy,
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
