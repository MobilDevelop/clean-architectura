import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';

/// Karta maydonlarining xatolari — har biri o'z maydoni tagida (7.5).
abstract final class CardIssueText {
  static String? phone(CardFieldIssue issue) =>
      issue == CardFieldIssue.phoneIncomplete ? "Telefon raqamini to'liq kiriting" : null;

  static String? number(CardFieldIssue issue) =>
      issue == CardFieldIssue.numberIncomplete ? "Karta raqamini to'liq kiriting" : null;

  static String? expiry(CardFieldIssue issue) => switch (issue) {
    CardFieldIssue.expiryIncomplete => "Amal muddatini to'liq kiriting",
    CardFieldIssue.expiryInvalid => "Oy 01 dan 12 gacha bo'ladi",
    _ => null,
  };
}
