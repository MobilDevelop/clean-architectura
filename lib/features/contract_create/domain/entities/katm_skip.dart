import 'package:equatable/equatable.dart';

/// KATM/MIB tekshiruvini o'tkazib yuborish sababi turi.
final class SkipReason extends Equatable {
  const SkipReason({required this.id, required this.name});

  final int id;
  final String name;

  bool get isEmpty => id == 0;

  @override
  List<Object?> get props => [id, name];
}

enum KatmSkipIssue { none, reasonMissing, commentMissing }

final class KatmSkipForm extends Equatable {
  const KatmSkipForm({this.reason = const SkipReason(id: 0, name: ''), this.comment = ''});

  final SkipReason reason;
  final String comment;

  KatmSkipIssue get issue {
    if (reason.isEmpty) return KatmSkipIssue.reasonMissing;
    if (comment.trim().isEmpty) return KatmSkipIssue.commentMissing;

    return KatmSkipIssue.none;
  }

  KatmSkipForm copyWith({SkipReason? reason, String? comment}) =>
      KatmSkipForm(reason: reason ?? this.reason, comment: comment ?? this.comment);

  @override
  List<Object?> get props => [reason, comment];
}

final class KatmSkipParams extends Equatable {
  const KatmSkipParams({required this.contractId, required this.form});

  final int contractId;
  final KatmSkipForm form;

  @override
  List<Object?> get props => [contractId, form];
}
