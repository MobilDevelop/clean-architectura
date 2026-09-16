part of 'guarantor_instruments_bloc.dart';

final class InstrumentsState extends Equatable {
  const InstrumentsState({
    required this.ref,
    required this.isLoading,
    required this.server,
    required this.selected,
    required this.card,
    required this.issue,
    required this.conflict,
    required this.isSaving,
    required this.isSaved,
    this.failure,
  });

  const InstrumentsState.initial(this.ref)
    : isLoading = false,
      server = null,
      selected = const <InstrumentType>{},
      card = const InstrumentCardDraft(),
      issue = InstrumentIssue.none,
      conflict = null,
      isSaving = false,
      isSaved = false,
      failure = null;

  final GuarantorRef ref;
  final bool isLoading;

  /// `null` — serverdagi holat hali o'qilmagan.
  final GuarantorInstruments? server;

  final Set<InstrumentType> selected;
  final InstrumentCardDraft card;
  final InstrumentIssue issue;

  /// Oxirgi urinishda qaysi instrument bilan ziddiyat chiqdi.
  final InstrumentType? conflict;

  final bool isSaving;
  final bool isSaved;
  final Failure? failure;

  bool get isReady => server != null;

  bool get showCard => selected.contains(InstrumentType.p2p);

  /// Serverda karta bor va xodim maydonlarga tegmagan — qayta yuborish shart
  /// emas, backend eskisini saqlab qoladi.
  bool get needsCard => showCard && (server?.card == null || !card.isUntouched);

  InstrumentsState copyWith({
    bool? isLoading,
    GuarantorInstruments? server,
    Set<InstrumentType>? selected,
    InstrumentCardDraft? card,
    InstrumentIssue? issue,
    InstrumentType? conflict,
    bool clearConflict = false,
    bool? isSaving,
    bool? isSaved,
    Failure? failure,
    bool clearFailure = false,
  }) => InstrumentsState(
    ref: ref,
    isLoading: isLoading ?? this.isLoading,
    server: server ?? this.server,
    selected: selected ?? this.selected,
    card: card ?? this.card,
    issue: issue ?? this.issue,
    conflict: clearConflict ? null : conflict ?? this.conflict,
    isSaving: isSaving ?? this.isSaving,
    isSaved: isSaved ?? this.isSaved,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    ref,
    isLoading,
    server,
    selected,
    card,
    issue,
    conflict,
    isSaving,
    isSaved,
    failure,
  ];
}
