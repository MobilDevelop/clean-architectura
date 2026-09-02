import 'package:colloborator_v3/features/customers/domain/entities/face_check_form.dart';

/// Kiritish xatosining matni. Har biri o'z maydoni tagida chiqadi (7.5).
abstract final class FaceCheckIssueText {
  static String? series(FaceCheckIssue issue) => switch (issue) {
    FaceCheckIssue.incompleteSeries => "Ikki harf",
    _ => null,
  };

  static String? number(FaceCheckIssue issue) => switch (issue) {
    FaceCheckIssue.incompleteNumber => "Yetti raqam kiritiladi",
    _ => null,
  };

  static String? birthday(FaceCheckIssue issue) => switch (issue) {
    FaceCheckIssue.incompleteDate => "Sanani to'liq kiriting",
    FaceCheckIssue.invalidDate => "Bunday sana mavjud emas",
    FaceCheckIssue.futureDate => "Sana kelajakda bo'lishi mumkin emas",
    FaceCheckIssue.tooYoung => "Pasport ${FaceCheckForm.passportAge} yoshdan beriladi",
    _ => null,
  };
}
