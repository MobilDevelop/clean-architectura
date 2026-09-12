part of 'release_bloc.dart';

final class ReleaseState extends Equatable {
  const ReleaseState({
    required this.contract,
    required this.isChecking,
    required this.requirements,
    required this.draft,
    required this.issue,
    required this.isSubmitting,
    required this.isDone,
    required this.camera,
    this.failure,
  });

  const ReleaseState.initial(this.contract)
    : isChecking = false,
      requirements = null,
      draft = const ReleaseDraft(),
      issue = ReleaseIssue.none,
      isSubmitting = false,
      isDone = false,
      camera = CameraIssue.none,
      failure = null;

  final OutputContract contract;

  final bool isChecking;

  /// `null` — talablar hali o'qilmagan.
  final IcloudRequirements? requirements;

  final ReleaseDraft draft;

  /// Faqat yuborishga urinilgandan keyin to'ldiriladi: forma ochilishi bilan
  /// qizil yozuv chiqishi kerak emas.
  final ReleaseIssue issue;

  final bool isSubmitting;

  /// Chiqim berildi — oyna yopiladi va ro'yxat yangilanadi.
  final bool isDone;

  final CameraIssue camera;

  final Failure? failure;

  /// Talablar bajarilgan — surat va kod so'raladi.
  ///
  /// Talab o'qilmaguncha `false`: o'qilmagan holatni «bajarilgan» deb
  /// hisoblash tekshiruvni jimgina o'chirib qo'yardi.
  bool get isReady => requirements?.isSatisfied ?? false;

  /// To'ldirilishi kerak bo'lgan qurilmalar soni.
  int get pendingDevices =>
      requirements?.devices.where((IcloudDevice device) => !device.isFilled).length ?? 0;

  ReleaseState copyWith({
    bool? isChecking,
    IcloudRequirements? requirements,
    ReleaseDraft? draft,
    ReleaseIssue? issue,
    bool? isSubmitting,
    bool? isDone,
    CameraIssue? camera,
    Failure? failure,
    bool clearFailure = false,
  }) => ReleaseState(
    contract: contract,
    isChecking: isChecking ?? this.isChecking,
    requirements: requirements ?? this.requirements,
    draft: draft ?? this.draft,
    issue: issue ?? this.issue,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isDone: isDone ?? this.isDone,
    camera: camera ?? this.camera,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    contract,
    isChecking,
    requirements,
    draft,
    issue,
    isSubmitting,
    isDone,
    camera,
    failure,
  ];
}
