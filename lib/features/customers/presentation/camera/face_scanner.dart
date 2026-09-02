import 'dart:io';

import 'package:camera/camera.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_placement.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Kamera kadrini domain tushunadigan o'lchamlarga o'giradi.
///
/// Nega alohida klass: aylantirish va ko'zgu hisobi shu yerda tugaydi.
/// `FacePlacementRule` ga tayyor, ekranga mos koordinatalar boradi va u
/// platformani umuman bilmaydi.
final class FaceScanner {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      // Ko'z ochiqligi shundan keladi — yopiq ko'z bilan olingan rasmni server
      // rad etadi.
      enableClassification: true,
      enableTracking: true,
      minFaceSize: .15,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  static const Map<DeviceOrientation, int> _rotations = <DeviceOrientation, int>{
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  bool _busy = false;

  /// Oldingi kadr hali tekshirilayotgan bo'lsa yangisi tashlab yuboriladi —
  /// navbat yig'ilsa kechikish sekundlarga chiqadi.
  bool get isBusy => _busy;

  Future<List<FaceGeometry>?> scan({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation orientation,
  }) async {
    if (_busy) return null;
    _busy = true;

    try {
      final InputImage? input = _toInputImage(image: image, camera: camera, orientation: orientation);
      if (input == null) return null;

      final List<Face> faces = await _detector.processImage(input);
      final InputImageMetadata? metadata = input.metadata;
      if (metadata == null) return null;

      // Android ML Kit koordinatalarni **aylantirilgan** kadrda qaytaradi, ya'ni
      // 90°/270° da eni va bo'yi almashadi. iOS esa buferni allaqachon tik
      // holatda beradi va koordinatalar asl kadrda qoladi — almashtirilsa
      // masofa hisobi kadr nisbati barobar (~1.8x) xato chiqadi.
      final bool swapped =
          !Platform.isIOS &&
          (metadata.rotation == InputImageRotation.rotation90deg ||
              metadata.rotation == InputImageRotation.rotation270deg);

      final double frameWidth = swapped ? metadata.size.height : metadata.size.width;
      final double frameHeight = swapped ? metadata.size.width : metadata.size.height;

      // Oldingi kamera ekranda ko'zgudek ko'rsatiladi: foydalanuvchi o'ngga
      // siljiganda kadrda chapga siljiydi.
      final bool mirrored = camera.lensDirection == CameraLensDirection.front;

      return faces.map((Face face) => _toGeometry(face, frameWidth, frameHeight, mirrored)).toList();
    } finally {
      _busy = false;
    }
  }

  FaceGeometry _toGeometry(Face face, double frameWidth, double frameHeight, bool mirrored) {
    final double centerX = face.boundingBox.center.dx / frameWidth;

    return FaceGeometry(
      centerX: mirrored ? 1 - centerX : centerX,
      centerY: face.boundingBox.center.dy / frameHeight,
      width: face.boundingBox.width / frameWidth,
      yaw: face.headEulerAngleY ?? 0,
      roll: face.headEulerAngleZ ?? 0,
      pitch: face.headEulerAngleX ?? 0,
      eyesOpen: _eyesOpen(face),
    );
  }

  /// Bitta ko'z aniqlanmasa ham qaror ikkinchisiga qarab chiqadi; ikkalasi
  /// ham noma'lum bo'lsa tekshiruv o'tkazib yuboriladi.
  double? _eyesOpen(Face face) {
    final double? left = face.leftEyeOpenProbability;
    final double? right = face.rightEyeOpenProbability;

    if (left == null) return right;
    if (right == null) return left;

    return left < right ? left : right;
  }

  InputImage? _toInputImage({
    required CameraImage image,
    required CameraDescription camera,
    required DeviceOrientation orientation,
  }) {
    final InputImageRotation? rotation = _rotationOf(camera: camera, orientation: orientation);
    if (rotation == null) return null;

    if (image.planes.isEmpty) return null;

    // Kamera aynan shu formatda so'ralgan — `FaceCameraController` ga qarang.
    final InputImageFormat format = Platform.isAndroid ? InputImageFormat.nv21 : InputImageFormat.bgra8888;

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  /// Flex'da faqat `sensorOrientation` olingan, qurilma yo'nalishi esa
  /// hisobga olinmagan — shuning uchun koordinatalar surilib, chegaralar
  /// qo'lda yamalgan edi.
  InputImageRotation? _rotationOf({required CameraDescription camera, required DeviceOrientation orientation}) {
    if (Platform.isIOS) return InputImageRotationValue.fromRawValue(camera.sensorOrientation);

    final int? deviceRotation = _rotations[orientation];
    if (deviceRotation == null) return null;

    final int compensated = camera.lensDirection == CameraLensDirection.front
        ? (camera.sensorOrientation + deviceRotation) % 360
        : (camera.sensorOrientation - deviceRotation + 360) % 360;

    return InputImageRotationValue.fromRawValue(compensated);
  }

  Future<void> close() => _detector.close();
}
