import 'package:colloborator_v3/features/contract_create/presentation/guarantors/contract_guarantors_bloc.dart';

/// Kafil qo'shishga to'sqinlik qilgan qoidaning matni.
abstract final class GuarantorIssueText {
  static String? of(GuarantorIssue issue) => switch (issue) {
    GuarantorIssue.none => null,
    GuarantorIssue.limitReached => "Ko'pi bilan 3 ta kafil qo'shiladi",
    GuarantorIssue.selfGuarantee => "Mijoz o'ziga kafil bo'la olmaydi",
    GuarantorIssue.duplicate => "Bu mijoz allaqachon kafil qilib qo'shilgan",
  };
}
