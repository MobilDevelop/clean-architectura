/// Kredit kalkulyator ekranining matnlari.
abstract final class CalculatorText {
  static const String title = "Kredit kalkulyator";

  static const String description =
      "Tovar narxi, muddat, Front marja va Bek marjani kiriting — oylik "
      "to'lov va shartnoma qiymati avtomatik hisoblanadi. Bu faqat tezkor "
      "taxmin, yakuniy summa mijoz va tovar tanlangandan keyin aniqlashadi.";

  static const String priceLabel = "Tovar narxi";
  static const String priceHint = "Kirim narxi, so'm";

  static const String termLabel = "Muddat";
  static const String termHint = "Tanlang";
  static String termValue(int months) => "$months oy";

  static const String frontMarginLabel = "Front marja, %";
  static const String backMarginLabel = "Bek marja, %";
  static String marginHint(int min, int max) => "$min% — $max% oralig'ida";

  static const String resultTitle = "Hisob-kitob";
  static const String priceRow = "Kirim narxi";
  static const String frontMarginRow = "Front marja";
  static const String sellingPriceRow = "Sotish narxi";
  static const String backMarginRow = "Bek marja";
  static const String totalPriceRow = "Shartnoma qiymati";
  static const String monthlyPaymentRow = "Oylik to'lov";
  static const String lastMonthPaymentRow = "Oxirgi oy to'lovi";

  static const String noResult = "—";

  static const String roundingHint =
      "Oylik to'lov yuqoriga yaxlitlangani uchun oxirgi oyda farq qaytariladi";
}
