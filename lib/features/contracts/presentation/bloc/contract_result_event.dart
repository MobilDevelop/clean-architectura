part of 'contract_result_bloc.dart';

sealed class ContractResultEvent extends Equatable {
  const ContractResultEvent();

  @override
  List<Object> get props => [];
}

final class ScoringRequested extends ContractResultEvent {
  const ScoringRequested();
}

/// MIB tabi ochildi: ishtirokchilar va birinchisining hisoboti so'raladi.
final class MibOpened extends ContractResultEvent {
  const MibOpened();
}

/// KATM tabi ochildi. Ishtirokchilar hali kelmagan bo'lsa avval ular olinadi.
final class KatmOpened extends ContractResultEvent {
  const KatmOpened();
}

final class ParticipantSelected extends ContractResultEvent {
  const ParticipantSelected(this.clientId);

  final int clientId;

  @override
  List<Object> get props => [clientId];
}

final class MibRetried extends ContractResultEvent {
  const MibRetried();
}

final class KatmRetried extends ContractResultEvent {
  const KatmRetried();
}

final class ScoringFailureHandled extends ContractResultEvent {
  const ScoringFailureHandled();
}
