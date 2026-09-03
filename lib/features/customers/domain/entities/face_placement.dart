import 'package:equatable/equatable.dart';

enum FacePlacement {
  noFace,
  manyFaces,
  tooFar,
  tooClose,
  moveLeft,
  moveRight,
  moveUp,
  moveDown,
  turnHead,
  tiltHead,
  eyesClosed,
  raiseHead,
  lowerHead,
  ready,
}

/// Kadrda topilgan yuzning o'lchamlari.
///
/// Barcha qiymatlar **ekran koordinatalarida** va 0..1 ga normallashtirilgan —
/// aylantirish va oldingi kameradagi ko'zguni chaqiruvchi hal qiladi. Shu
/// sababli qoida platformaga bog'liq emas.
final class FaceGeometry extends Equatable {
  const FaceGeometry({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.yaw,
    required this.roll,
    required this.pitch,
    this.eyesOpen,
  });

  /// Yuz markazi kadr kengligiga nisbatan: 0 — chap chekka, 1 — o'ng chekka.
  final double centerX;
  final double centerY;

  /// Yuz kengligi kadr kengligiga nisbatan — masofa shundan bilinadi.
  final double width;

  /// Boshning burilishi, gradusda.
  final double yaw;
  final double roll;
  final double pitch;

  /// Ikki ko'zning ochiqligidan kichigi, 0..1. ML Kit ayta olmasa `null` —
  /// bunda tekshiruv o'tkazib yuboriladi, yo'qsa qorong'ida rasm olinmay
  /// qoladi.
  final double? eyesOpen;

  @override
  List<Object?> get props => [centerX, centerY, width, yaw, roll, pitch, eyesOpen];
}

/// Yuz to'g'ri turganini aniqlaydi.
///
/// Nega domainda: "juda uzoq" va "juda yaqin" — biznes talabi, chunki server
/// bunday rasmni rad etadi. Chegaralar bitta joyda va kamerasiz test qilinadi.
abstract final class FacePlacementRule {
  /// Yuz kadr kengligining shuncha qismini egallashi kerak.
  ///
  /// Hisob flex'da qurilmada sozlangan chegaralardan chiqarilgan. Flex Android'da
  /// `box.width / 1280` bo'yicha 0.40–0.55 ishlatgan, ML Kit esa ramkani
  /// aylantirilgan kadrda (eni 720) qaytaradi — ya'ni haqiqiy nisbat 71–98%.
  /// iOS'da bufer tik keladi va 0.72–0.85, ya'ni 72–85%.
  /// Ikkala oraliq ustma-ust tushmaydi; quyidagi qiymatlar — o'rtachasi va
  /// qurilmada sinab tanlangan. O'zgartirilsa faqat shu ikki raqam o'zgaradi.
  static const double minWidth = .68;
  static const double maxWidth = .95;

  /// Markazdan ruxsat etilgan chetlanish.
  static const double maxOffset = .12;

  /// Ko'z shundan yopiqroq bo'lsa rasm olinmaydi.
  static const double minEyeOpen = .4;

  static const double maxYaw = 14;
  static const double maxRoll = 14;
  static const double maxPitch = 16;

  static FacePlacement of(List<FaceGeometry> faces) {
    if (faces.isEmpty) return FacePlacement.noFace;
    if (faces.length > 1) return FacePlacement.manyFaces;

    final FaceGeometry face = faces.first;

    if (face.width < minWidth) return FacePlacement.tooFar;
    if (face.width > maxWidth) return FacePlacement.tooClose;

    final double offsetX = face.centerX - .5;
    if (offsetX < -maxOffset) return FacePlacement.moveRight;
    if (offsetX > maxOffset) return FacePlacement.moveLeft;

    final double offsetY = face.centerY - .5;
    if (offsetY < -maxOffset) return FacePlacement.moveDown;
    if (offsetY > maxOffset) return FacePlacement.moveUp;

    if (face.yaw.abs() > maxYaw) return FacePlacement.turnHead;
    if (face.roll.abs() > maxRoll) return FacePlacement.tiltHead;
    if (face.pitch > maxPitch) return FacePlacement.lowerHead;
    if (face.pitch < -maxPitch) return FacePlacement.raiseHead;

    final double? eyes = face.eyesOpen;
    if (eyes != null && eyes < minEyeOpen) return FacePlacement.eyesClosed;

    return FacePlacement.ready;
  }
}

/// Yuz yetarlicha uzoq qimirlamay turganini kuzatadi.
///
/// Bitta kadrda rasmga olish xato: qo'l titraganda ham bir kadr to'g'ri
/// chiqadi. Vaqt tashqaridan beriladi (9.4).
final class FaceHold {
  FaceHold({this.duration = const Duration(milliseconds: 1200)});

  final Duration duration;
  DateTime? _since;

  /// `true` — yuz [duration] davomida to'g'ri turdi.
  bool add(FacePlacement placement, DateTime now) {
    if (placement != FacePlacement.ready) {
      _since = null;
      return false;
    }

    final DateTime start = _since ??= now;

    return now.difference(start) >= duration;
  }

  void reset() => _since = null;
}
