import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Kamera ochilmaganda nima bo'lganini aytadi — sabab yo'qolmasligi kerak.
enum CameraStartIssue { none, denied, notFound, failed }

/// Oldingi kamerani ochadi va rasm oladi.
///
/// Nega alohida: sahifa faqat ko'rsatadi. Kamera hayoti — ochish, kadr oqimi,
/// suratga olish, yopish — shu klassda.
final class FaceCameraController {
  CameraController? _controller;
  CameraDescription? _camera;

  /// Rasmning qisqa tomoni shu o'lchamga tushiriladi. Yuzni solishtirish
  /// uchun bundan kattasi kerak emas, base64 esa hajmni yana 33% oshiradi.
  static const int _targetSide = 720;
  static const int _quality = 85;

  CameraController? get controller => _controller;
  CameraDescription? get camera => _camera;
  bool get isReady => _controller?.value.isInitialized ?? false;

  Future<CameraStartIssue> start() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) return CameraStartIssue.notFound;

      final int index = cameras.indexWhere((CameraDescription c) => c.lensDirection == CameraLensDirection.front);
      final CameraDescription camera = cameras[index == -1 ? 0 : index];

      final CameraController controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();

      _controller = controller;
      _camera = camera;

      return CameraStartIssue.none;
    } on CameraException catch (error) {
      return error.code == 'CameraAccessDenied' ? CameraStartIssue.denied : CameraStartIssue.failed;
    } catch (_) {
      return CameraStartIssue.failed;
    }
  }

  Future<void> startStream(void Function(CameraImage) onFrame) async {
    final CameraController? controller = _controller;
    if (controller == null || controller.value.isStreamingImages) return;

    await controller.startImageStream(onFrame);
  }

  Future<void> stopStream() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isStreamingImages) return;

    await controller.stopImageStream();
  }

  /// Rasm olinmasa `null` — chaqiruvchi buni foydalanuvchiga aytadi.
  Future<File?> capture() async {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return null;

    try {
      await stopStream();
      final XFile shot = await controller.takePicture();

      return _compressed(File(shot.path));
    } catch (_) {
      return null;
    }
  }

  /// Har doim siqiladi: rasm hajmi qurilmaga qarab keskin farq qiladi, base64
  /// esa uni yana 33% oshiradi. Siqish plagin ichida, alohida oqimda ketadi.
  Future<File> _compressed(File file) async {
    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      '${file.parent.path}/small_${DateTime.now().millisecondsSinceEpoch}.jpg',
      quality: _quality,
      minWidth: _targetSide,
      minHeight: _targetSide,
      format: CompressFormat.jpeg,
    );

    return result == null ? file : File(result.path);
  }

  Future<void> dispose() async {
    final CameraController? controller = _controller;
    _controller = null;
    _camera = null;

    if (controller == null) return;

    if (controller.value.isStreamingImages) await controller.stopImageStream();
    await controller.dispose();
  }
}
