part of 'contract_guarantors_bloc.dart';

/// Kafil qo'shishga to'sqinlik qiladigan qoidalar.
enum GuarantorIssue { none, limitReached, selfGuarantee, duplicate }

final class ContractGuarantorsState extends Equatable {
  const ContractGuarantorsState({
    required this.contractId,
    required this.clientId,
    required this.guarantors,
    required this.isAdding,
    required this.issue,
    required this.revision,
    this.busyId,
    this.failure,
  });

  const ContractGuarantorsState.initial({
    required this.contractId,
    required this.clientId,
    required this.guarantors,
  }) : isAdding = false,
       issue = GuarantorIssue.none,
       revision = 0,
       busyId = null,
       failure = null;

  /// Ko'pi bilan shuncha kafil qo'shiladi.
  static const int maxGuarantors = 3;

  final int contractId;

  /// Qarz oluvchining id si — u o'ziga kafil bo'lolmaydi.
  final int clientId;

  final List<ContractGuarantor> guarantors;
  final bool isAdding;
  final GuarantorIssue issue;
  final int revision;

  /// Qaysi qator o'chirilyapti.
  final int? busyId;

  final Failure? failure;

  bool get isFull => guarantors.length >= maxGuarantors;

  bool get isBusy => isAdding || busyId != null;

  ContractGuarantorsState copyWith({
    List<ContractGuarantor>? guarantors,
    bool? isAdding,
    GuarantorIssue? issue,
    int? revision,
    int? busyId,
    Failure? failure,
    bool clearFailure = false,
    bool clearBusyId = false,
  }) => ContractGuarantorsState(
    contractId: contractId,
    clientId: clientId,
    guarantors: guarantors ?? this.guarantors,
    isAdding: isAdding ?? this.isAdding,
    issue: issue ?? this.issue,
    revision: revision ?? this.revision,
    busyId: clearBusyId ? null : busyId ?? this.busyId,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    contractId,
    clientId,
    guarantors,
    isAdding,
    issue,
    revision,
    busyId,
    failure,
  ];
}
