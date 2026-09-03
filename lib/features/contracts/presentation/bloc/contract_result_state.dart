part of 'contract_result_bloc.dart';

final class ContractResultState extends Equatable {
  const ContractResultState({
    required this.isScoringLoading,
    required this.isScoringLoaded,
    required this.results,
    required this.flexMessages,
    required this.participants,
    required this.isParticipantsLoading,
    required this.isMibLoading,
    required this.isKatmLoading,
    required this.isKatmOpened,
    this.selectedClientId,
    this.mib,
    this.katm,
    this.scoringFailure,
    this.participantsFailure,
    this.mibFailure,
    this.katmFailure,
  });

  const ContractResultState.initial()
    : isScoringLoading = false,
      isScoringLoaded = false,
      results = const <ContractScoring>[],
      flexMessages = const <String>[],
      participants = const <CreditParticipant>[],
      isParticipantsLoading = false,
      isMibLoading = false,
      isKatmLoading = false,
      isKatmOpened = false,
      selectedClientId = null,
      mib = null,
      katm = null,
      scoringFailure = null,
      participantsFailure = null,
      mibFailure = null,
      katmFailure = null;

  final bool isScoringLoading;

  /// So'rov bir marta muvaffaqiyatli tugadi — bo'sh ro'yxat "natija yo'q" degani.
  final bool isScoringLoaded;

  final List<ContractScoring> results;
  final List<String> flexMessages;

  final List<CreditParticipant> participants;
  final bool isParticipantsLoading;
  final bool isMibLoading;
  final bool isKatmLoading;

  /// KATM tabi ochilganmi. Ishtirokchi almashtirilganda hisobot shu bayroqqa
  /// qarab qayta so'raladi — aks holda tab bo'sh qolardi.
  final bool isKatmOpened;

  final int? selectedClientId;
  final MibReport? mib;
  final KatmReport? katm;

  // Har bir so'rovning o'z xatosi: bir tabning nosozligi ikkinchisining
  // ma'lumotini ekrandan o'chirmasligi kerak (6.4).
  final Failure? scoringFailure;
  final Failure? participantsFailure;
  final Failure? mibFailure;
  final Failure? katmFailure;

  ContractResultState copyWith({
    bool? isScoringLoading,
    bool? isScoringLoaded,
    List<ContractScoring>? results,
    List<String>? flexMessages,
    List<CreditParticipant>? participants,
    bool? isParticipantsLoading,
    bool? isMibLoading,
    bool? isKatmLoading,
    bool? isKatmOpened,
    int? selectedClientId,
    MibReport? mib,
    KatmReport? katm,
    Failure? scoringFailure,
    Failure? participantsFailure,
    Failure? mibFailure,
    Failure? katmFailure,
    bool clearScoringFailure = false,
    bool clearParticipantsFailure = false,
    bool clearMibFailure = false,
    bool clearKatmFailure = false,
    bool clearMib = false,
    bool clearKatm = false,
  }) => ContractResultState(
    isScoringLoading: isScoringLoading ?? this.isScoringLoading,
    isScoringLoaded: isScoringLoaded ?? this.isScoringLoaded,
    results: results ?? this.results,
    flexMessages: flexMessages ?? this.flexMessages,
    participants: participants ?? this.participants,
    isParticipantsLoading: isParticipantsLoading ?? this.isParticipantsLoading,
    isMibLoading: isMibLoading ?? this.isMibLoading,
    isKatmLoading: isKatmLoading ?? this.isKatmLoading,
    isKatmOpened: isKatmOpened ?? this.isKatmOpened,
    selectedClientId: selectedClientId ?? this.selectedClientId,
    mib: clearMib ? null : mib ?? this.mib,
    katm: clearKatm ? null : katm ?? this.katm,
    scoringFailure: clearScoringFailure ? null : scoringFailure ?? this.scoringFailure,
    participantsFailure: clearParticipantsFailure ? null : participantsFailure ?? this.participantsFailure,
    mibFailure: clearMibFailure ? null : mibFailure ?? this.mibFailure,
    katmFailure: clearKatmFailure ? null : katmFailure ?? this.katmFailure,
  );

  @override
  List<Object?> get props => [
    isScoringLoading,
    isScoringLoaded,
    results,
    flexMessages,
    participants,
    isParticipantsLoading,
    isMibLoading,
    isKatmLoading,
    isKatmOpened,
    selectedClientId,
    mib,
    katm,
    scoringFailure,
    participantsFailure,
    mibFailure,
    katmFailure,
  ];
}
