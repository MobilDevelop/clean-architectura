part of 'underwriter_bloc.dart';

enum UnderwriterWrite { none, uploading, saving }

final class UnderwriterState extends Equatable {
  const UnderwriterState({
    required this.args,
    required this.sections,
    required this.current,
    required this.positions,
    required this.brands,
    required this.models,
    required this.isLoading,
    required this.isModelsLoading,
    required this.write,
    required this.issue,
    required this.fileIssue,
    required this.savedCount,
    this.data,
    this.failure,
  });

  UnderwriterState.initial(this.args)
    : sections = UnderwriterPlan.of(args),
      current = UnderwriterPlan.of(args).first,
      positions = const <MilitaryPosition>[],
      brands = const <UnderwriterOption>[],
      models = const <UnderwriterOption>[],
      isLoading = false,
      isModelsLoading = false,
      write = UnderwriterWrite.none,
      issue = UnderwriterIssue.none,
      fileIssue = FileIssue.none,
      savedCount = 0,
      data = null,
      failure = null;

  final UnderwriterArgs args;

  /// Ko'rinadigan bo'limlar — ish joyi toifasi va daromad asosiga qarab.
  final List<UnderwriterKind> sections;

  final UnderwriterKind current;

  final List<MilitaryPosition> positions;
  final List<UnderwriterOption> brands;
  final List<UnderwriterOption> models;

  final bool isLoading;
  final bool isModelsLoading;
  final UnderwriterWrite write;

  /// Saqlashga to'sqinlik qilayotgan kamchilik — "Tasdiqlash" bosilganda.
  final UnderwriterIssue issue;

  /// Fayl qo'shib bo'lmaganining sababi.
  final FileIssue fileIssue;

  /// Muvaffaqiyatli saqlashlar soni — ekran shu o'zgarganda xabar ko'rsatadi.
  final int savedCount;

  /// Serverdagi holat. `null` — hali yuklanmagan.
  final UnderwriterData? data;

  final Failure? failure;

  bool get isBusy => write != UnderwriterWrite.none;

  /// Ma'lumot yuklanmagan bo'lsa saqlash xavfli: `editId` nolda qolib,
  /// mavjud yozuv ustidan ikkinchisi yaratilib ketardi.
  bool get isReady => data != null;

  UnderwriterForm? get form => data?.formOf(current);

  UnderwriterState copyWith({
    UnderwriterKind? current,
    List<MilitaryPosition>? positions,
    List<UnderwriterOption>? brands,
    List<UnderwriterOption>? models,
    bool? isLoading,
    bool? isModelsLoading,
    UnderwriterWrite? write,
    UnderwriterIssue? issue,
    FileIssue? fileIssue,
    int? savedCount,
    UnderwriterData? data,
    Failure? failure,
    bool clearFailure = false,
  }) => UnderwriterState(
    args: args,
    sections: sections,
    current: current ?? this.current,
    positions: positions ?? this.positions,
    brands: brands ?? this.brands,
    models: models ?? this.models,
    isLoading: isLoading ?? this.isLoading,
    isModelsLoading: isModelsLoading ?? this.isModelsLoading,
    write: write ?? this.write,
    issue: issue ?? this.issue,
    fileIssue: fileIssue ?? this.fileIssue,
    savedCount: savedCount ?? this.savedCount,
    data: data ?? this.data,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    args,
    sections,
    current,
    positions,
    brands,
    models,
    isLoading,
    isModelsLoading,
    write,
    issue,
    fileIssue,
    savedCount,
    data,
    failure,
  ];
}
