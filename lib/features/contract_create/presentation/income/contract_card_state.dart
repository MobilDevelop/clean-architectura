part of 'contract_card_bloc.dart';

enum CardWrite { none, adding, removing }

final class ContractCardState extends Equatable {
  const ContractCardState({
    required this.contractId,
    required this.clientId,
    required this.card,
    required this.form,
    required this.write,
    required this.revision,
    this.issue = CardFieldIssue.none,
    this.failure,
  });

  const ContractCardState.initial({
    required this.contractId,
    required this.clientId,
    required this.card,
  }) : form = const CardForm(),
       write = CardWrite.none,
       revision = 0,
       issue = CardFieldIssue.none,
       failure = null;

  final int contractId;
  final int clientId;

  /// Serverdagi karta. Bo'sh bo'lsa hali biriktirilmagan.
  final ContractCard card;

  /// Kiritilayotgan karta.
  final CardForm form;

  final CardWrite write;

  /// Muvaffaqiyatli server yozuvlari soni — har biri qayta o'qishni chaqiradi.
  final int revision;

  final CardFieldIssue issue;
  final Failure? failure;

  bool get isBusy => write != CardWrite.none;

  bool get hasCard => !card.isEmpty;

  ContractCardState copyWith({
    ContractCard? card,
    CardForm? form,
    CardWrite? write,
    int? revision,
    CardFieldIssue? issue,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractCardState(
    contractId: contractId,
    clientId: clientId,
    card: card ?? this.card,
    form: form ?? this.form,
    write: write ?? this.write,
    revision: revision ?? this.revision,
    issue: issue ?? this.issue,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[contractId, clientId, card, form, write, revision, issue, failure];
}
