import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';

/// Imzolash oynasining foydalanuvchiga ko'rinadigan matnlari.
///
/// Nega bitta joyda: lokalizatsiyaga o'tishda kalitlar shu fayldan olinadi
/// va matn ekran bo'ylab sochilib yotmaydi.
abstract final class SigningText {
  static const String title = "Shartnomani imzolash";
  static const String schedule = "Grafik";

  static const String documentTitle = "Shartnoma matni";
  static const String openDocument = "Shartnoma matnini ochish";
  static const String documentUnread = "Yuzni tasdiqlashdan oldin shartnoma matnini oxirigacha o'qing";
  static const String documentRead = "Shartnoma matni o'qildi";
  static const String documentFailed = "Shartnoma matni ochilmadi";

  static const String participants = "Ishtirokchilar";
  static const String client = "Mijoz";
  static const String faceCheck = "Yuzni tasdiqlash";
  static const String faceChecked = "Yuz tasdiqlangan";
  static const String faceNeeded = "Imzolashdan oldin yuzni tasdiqlang";
  static const String sign = "Imzoni yuborish";
  static const String openSignature = "Imzo qo'yish";
  static const String signed = "Imzolangan";
  static const String clearSignature = "Tozalash";
  static const String commentHint = "Izoh (ixtiyoriy)";
  static const String emptySignature = "Avval imzo chizing";

  static const String finished = "Shartnoma to'liq imzolandi";

  /// Kamera ochilmadi — ruxsat berilmagan yoki qurilmada kamera yo'q.
  static const String cameraFailed = "Kamerani ochib bo'lmadi";

  static String guarantor(int order) => "Kafil $order";

  static String progress(ContractSigning signing) =>
      "${signing.signedCount} / ${signing.participants.length} imzolangan";
}
