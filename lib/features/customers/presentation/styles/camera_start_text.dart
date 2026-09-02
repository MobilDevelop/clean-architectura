import 'package:colloborator_v3/features/customers/presentation/camera/face_camera_controller.dart';

/// Kamera ochilmaganda ko'rsatiladigan matn.
abstract final class CameraStartText {
  static String of(CameraStartIssue issue) => switch (issue) {
    CameraStartIssue.none => '',
    CameraStartIssue.denied => "Kameraga ruxsat berilmagan.\nSozlamalardan ruxsat bering",
    CameraStartIssue.notFound => "Qurilmada kamera topilmadi",
    CameraStartIssue.failed => "Kamera ishga tushmadi.\nIlovani qayta oching",
  };
}
