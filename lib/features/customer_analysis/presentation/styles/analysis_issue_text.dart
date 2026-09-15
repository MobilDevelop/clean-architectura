import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';

/// Har bir xato o'z maydoni tagida chiqadi (7.5).
abstract final class AnalysisIssueText {
  static String? inps(AnalysisIssue issue) =>
      issue == AnalysisIssue.inpsIncomplete ? "INPS raqami 14 xonadan iborat bo'lishi kerak" : null;

  static String? contactPhone(AnalysisIssue issue) =>
      issue == AnalysisIssue.contactPhoneInvalid ? "Telefon raqami to'liq kiritilmadi" : null;

  static String? cardPhone(AnalysisIssue issue) =>
      issue == AnalysisIssue.cardPhoneInvalid ? "Telefon raqami to'liq kiritilmadi" : null;

  static String? cardNumber(AnalysisIssue issue) =>
      issue == AnalysisIssue.cardNumberInvalid ? "Karta raqami to'liq kiritilmadi" : null;

  static String? cardExpiry(AnalysisIssue issue) =>
      issue == AnalysisIssue.cardExpiryInvalid ? "Karta muddati noto'g'ri" : null;
}
