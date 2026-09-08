import 'package:equatable/equatable.dart';

/// Rahbarning qarori.
enum BonusDecision {
  approved,
  rejected;

  /// Serverga shu satr bilan ketadi.
  String get code => this == BonusDecision.approved ? 'APPROVED' : 'REJECTED';
}

enum BonusIssue { none, amountMissing, amountTooLarge, commentTooShort, commentTooLong }

/// Bonus formasi.
///
/// Izoh chegaralari domainda: backend ham shuni tekshiradi (7.3).
final class BonusForm extends Equatable {
  const BonusForm({required this.decision, this.amount = 0, this.comment = ''});

  static const int minComment = 3;
  static const int maxComment = 255;

  final BonusDecision decision;
  final int amount;
  final String comment;

  BonusIssue issueAt({required int availableAmount}) {
    // Rad etishda summa tekshirilmaydi — u qo'llanmaydi.
    if (decision == BonusDecision.approved) {
      if (amount <= 0) return BonusIssue.amountMissing;
      if (amount > availableAmount) return BonusIssue.amountTooLarge;
    }

    if (comment.trim().length < minComment) return BonusIssue.commentTooShort;
    if (comment.trim().length > maxComment) return BonusIssue.commentTooLong;

    return BonusIssue.none;
  }

  BonusForm copyWith({BonusDecision? decision, int? amount, String? comment}) => BonusForm(
    decision: decision ?? this.decision,
    amount: amount ?? this.amount,
    comment: comment ?? this.comment,
  );

  @override
  List<Object?> get props => [decision, amount, comment];
}

final class SendBonusParams extends Equatable {
  const SendBonusParams({required this.contractId, required this.form});

  final int contractId;
  final BonusForm form;

  @override
  List<Object?> get props => [contractId, form];
}
