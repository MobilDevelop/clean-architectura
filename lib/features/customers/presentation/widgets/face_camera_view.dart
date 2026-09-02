import 'package:camera/camera.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Doira ichidagi kamera tasviri. Doira rangi yuz to'g'ri turganini ko'rsatadi.
final class FaceCameraView extends StatelessWidget {
  const FaceCameraView({super.key, required this.controller, required this.isReady, required this.size});

  final CameraController? controller;

  /// Yuz to'g'ri joylashgan — halqa yashil bo'ladi.
  final bool isReady;

  final double size;

  @override
  Widget build(BuildContext context) {
    final CameraController? camera = controller;
    final Color ring = isReady ? AppTheme.colors.primary : AppTheme.colors.grey1;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.colors.btnBackcolor,
        border: Border.all(color: ring, width: ScreenSize.h4),
      ),
      child: camera == null || !camera.value.isInitialized
          ? Center(child: CircularProgressIndicator(color: AppTheme.colors.primary))
          : ClipOval(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: camera.value.previewSize?.height ?? size,
                  height: camera.value.previewSize?.width ?? size,
                  child: CameraPreview(camera),
                ),
              ),
            ),
    );
  }
}
