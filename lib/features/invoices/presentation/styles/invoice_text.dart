/// Fakturalar ekranining matnlari.
abstract final class InvoiceText {
  static const String title = "Fakturalar";

  static const String emptyTitle = "Faktura topilmadi";
  static const String emptyMessage = "Boshqa sanani tanlab ko'ring";

  static const String partner = "Ta'minotchi:";
  static const String amount = "Summa:";
  static const String contract = "Shartnoma kodi:";
  static const String status = "Status:";

  static const String filter = "Sana bo'yicha filtr";
  static const String filterSubtitle = "Kunni tanlang";

  /// Amallar oynasi.
  static String sheetTitle(int contractId) => "Faktura № $contractId";

  static const String open = "Ko'rish";
  static const String openHint = "Faylni ochish";
  static const String send = "Yuborish";
  static const String sendHint = "Ta'minotchiga";

  static const String noFile = "Bu fakturaning fayli yo'q";
  static const String openFailed = "Faylni ochadigan ilova topilmadi";
  static const String sent = "Faktura ta'minotchiga yuborildi";
}
