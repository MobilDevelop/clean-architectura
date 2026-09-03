import 'package:colloborator_v3/features/customers/presentation/camera/face_camera_controller.dart';

/// Surat olinmaganda ko'rsatiladigan matn.
abstract final class CaptureIssueText {
  static String of(CaptureIssue issue) => switch (issue) {
    CaptureIssue.none => '',
    CaptureIssue.notReady => "Kamera tayyor emas",
    CaptureIssue.failed => "Rasmni saqlab bo'lmadi.\nQurilmada joy bor-yo'qligini tekshiring",
  };
}
