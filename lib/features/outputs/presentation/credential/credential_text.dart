import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';

/// iCloud formasining matnlari.
abstract final class CredentialText {
  static const String title = "Qurilma";
  static const String save = "Saqlash";
  static const String saved = "Saqlandi";

  static const String client = "Mijoz F.I.O";
  static const String condition = "Telefon holati";
  static const String conditionHint = "Masalan: yangi, ochilmagan";
  static const String box = "Karobkasi bormi";
  static const String boxYes = "Bor";
  static const String boxNo = "Yo'q";
  static const String imei = "IMEI raqam";
  static const String imeiHint = "15 ta raqam";
  static const String imei2 = "IMEI2 raqam";
  static const String imei2Hint = "Bo'lsa kiriting";
  static const String serial = "Seriya raqam";
  static const String serialHint = "Qurilma seriya raqami";
  static const String login = "iCloud login";
  static const String loginHint = "pochta@icloud.com";
  static const String password = "iCloud parol";
  static const String passwordHint = "Parolni kiriting";
  static const String appleLogin = "Apple ID login";
  static const String applePassword = "Apple ID parol";
  static const String ownerHint = "Tanlang";
  static const String restriction = "Cheklov kodi";
  static const String restrictionHint = "4 ta raqam";
  static const String phone = "iCloud bog'langan raqam";
  static const String phoneHint = "+998";

  /// Apple ID egasining yozuvi.
  ///
  /// Ikkala qator ham serverga aynan shu ko'rinishda ketadi va xodim ularni
  /// flex'dan shunday biladi — tarjima qilinsa qaysi qator tanlanganini
  /// aniqlab bo'lmay qolardi. Ma'nosi backenddan so'ralgan.
  static String owner(AppleIdOwner value) => switch (value) {
    AppleIdOwner.own => 'OZINIKI',
    AppleIdOwner.personal => 'Личный',
  };

  /// Har bir xato o'z maydoni tagida (7.5).
  static String? of(IcloudIssue issue, IcloudIssue field) => issue == field ? _message(issue) : null;

  static String _message(IcloudIssue issue) => switch (issue) {
    IcloudIssue.none => '',
    IcloudIssue.conditionMissing => "Telefon holatini kiriting",
    IcloudIssue.boxMissing => "Karobka haqida belgilang",
    IcloudIssue.imeiShort => "IMEI ${IcloudCredential.imeiLength} ta raqamdan iborat",
    IcloudIssue.serialMissing => "Seriya raqamni kiriting",
    IcloudIssue.loginMissing => "iCloud loginni kiriting",
    IcloudIssue.passwordMissing => "iCloud parolni kiriting",
    IcloudIssue.appleLoginMissing => "Apple ID loginni tanlang",
    IcloudIssue.applePasswordMissing => "Apple ID parolni tanlang",
    IcloudIssue.restrictionShort => "Cheklov kodi ${IcloudCredential.restrictionLength} ta raqam",
    IcloudIssue.phoneShort => "Raqamni to'liq kiriting",
  };
}
