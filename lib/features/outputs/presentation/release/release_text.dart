import 'package:colloborator_v3/core/utils/camera_issue.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';

/// Chiqim berish oynasining matnlari.
abstract final class ReleaseText {
  static const String title = "Chiqim berish";
  static const String submit = "Tasdiqlash";
  static const String done = "Chiqim berildi";

  static const String photoTitle = "Rasm olish uchun bosing";
  static const String photoHint = "Mijoz va tovar bir kadrda ko'rinishi shart";
  static const String photoChange = "O'zgartirish";

  static const String divider = "keyin";
  static String sentTo(String phone) => "$phone raqamiga yuborilgan SMS kodni kiriting";
  static const String codeHint = "Kodni kiriting";
  static const String waiting = "SMS kod 1-5 daqiqa ichida yetib keladi";
  static const String expired = "SMS kelmagan bo'lsa, adminga murojaat qiling";

  static const String checking = "iCloud talablari tekshirilmoqda…";
  static const String blockedTitle = "iCloud ma'lumotlari to'ldirilmagan";
  static String blockedMessage(int count) =>
      "$count ta qurilma uchun iCloud ma'lumotlari kiritilishi kerak. Chiqim shundan keyin ochiladi.";
  static const String blockedAction = "To'ldirish";

  /// Talab o'qilmagan holat — sabab xato yuzasida ko'rinadi, bu yerda faqat
  /// nima qilish kerakligi aytiladi.
  static const String unknownTitle = "Talablar o'qilmadi";
  static const String unknownMessage = "Chiqim berishdan oldin iCloud talablari tekshiriladi";
  static const String unknownAction = "Qayta tekshirish";

  /// Xato aynan yetishmayotgan maydon tagida chiqadi (7.5).
  static String? photo(ReleaseIssue issue) =>
      issue == ReleaseIssue.photoMissing ? "Tovarlar suratini oling" : null;

  static String? code(ReleaseIssue issue) => issue == ReleaseIssue.codeIncomplete
      ? "Kod ${ReleaseDraft.codeLength} belgidan iborat"
      : null;

  static String? camera(CameraIssue issue) => CameraIssueText.of(issue);
}
