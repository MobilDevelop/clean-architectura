import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';

abstract final class BonusIssueText {
  static String? amount(BonusIssue issue) => switch (issue) {
    BonusIssue.amountMissing => "Bonus summasini kiriting",
    BonusIssue.amountTooLarge => "Summa mavjud limitdan oshib ketdi",
    _ => null,
  };

  static String? comment(BonusIssue issue) => switch (issue) {
    BonusIssue.commentTooShort => "Izoh kamida ${BonusForm.minComment} belgidan iborat bo'ladi",
    BonusIssue.commentTooLong => "Izoh ${BonusForm.maxComment} belgidan oshmaydi",
    _ => null,
  };
}
