import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';

/// KATM/MIB skip formasidagi kamchiliklarning matni.
abstract final class KatmSkipIssueText {
  static String? reason(KatmSkipIssue issue) =>
      issue == KatmSkipIssue.reasonMissing ? "Sabab turini tanlang" : null;

  static String? comment(KatmSkipIssue issue) =>
      issue == KatmSkipIssue.commentMissing ? "Izohni kiriting" : null;
}
