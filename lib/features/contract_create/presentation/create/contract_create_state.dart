part of 'contract_create_bloc.dart';

final class ContractCreateState extends Equatable {
  const ContractCreateState({
    required this.args,
    required this.form,
    required this.issue,
    required this.isLoading,
    required this.isSubmitting,
    required this.isSubmitted,
    this.details,
    this.contractId,
    this.failure,
  });

  ContractCreateState.initial(this.args)
    : contractId = args.contractId,
      details = null,
      form = const ContractForm.initial(),
      issue = ContractFormIssue.none,
      isLoading = false,
      isSubmitting = false,
      isSubmitted = false,
      failure = null;

  final ContractCreateArgs args;

  /// Qoralama id si. Birinchi tovar qo'shilgach paydo bo'ladi.
  final int? contractId;

  /// Serverdagi holat. Qoralama yo'q bo'lsa `null`.
  final ContractDetails? details;

  /// Shartnoma yozuvining tahrirlanayotgan qismi — faqat yuborishda saqlanadi.
  final ContractForm form;

  /// "Yuborish" bosilganda hisoblanadi.
  final ContractFormIssue issue;

  final bool isLoading;
  final bool isSubmitting;
  final bool isSubmitted;
  final Failure? failure;

  /// Qo'shimcha ekranlar: qaysi biri ko'rinadi va qaysi biri hali ochilmaydi.
  ContractExtras get extras =>
      ContractExtras.of(details: details, form: form, canSkipKatm: args.canSkipKatm);

  /// Yuborishga to'sqinlik qilayotgan birinchi kamchilik.
  ContractFormIssue get currentIssue =>
      form.issueAt(productCount: productCount, hasCard: hasCard);

  bool get hasCard => !(details?.card.isEmpty ?? true);

  /// Karta biriktirilgan bo'lsa daromad asosi qulflanadi.
  bool get canChangeBasis => !hasCard;

  /// Kasb turi maydoni ko'rinadimi.
  bool get isOccupationVisible => form.isOccupationNeeded(hasCard: hasCard);

  bool get hasContract => contractId != null;

  int get productCount => details?.products.length ?? 0;

  /// Muddat va to'lov kuni faqat "Yuborish" da serverga ketadi — shu paytgacha
  /// ular mahalliy. Foydalanuvchi buni bilishi kerak (5.8).
  bool get hasUnsavedTerms => details != null && (details?.termMonths != form.termMonths || details?.paymentDay != form.paymentDay);

  ContractCreateState copyWith({
    int? contractId,
    ContractDetails? details,
    ContractForm? form,
    ContractFormIssue? issue,
    bool? isLoading,
    bool? isSubmitting,
    bool? isSubmitted,
    Failure? failure,
    bool clearFailure = false,
  }) => ContractCreateState(
    args: args,
    contractId: contractId ?? this.contractId,
    details: details ?? this.details,
    form: form ?? this.form,
    issue: issue ?? this.issue,
    isLoading: isLoading ?? this.isLoading,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    args,
    contractId,
    details,
    form,
    issue,
    isLoading,
    isSubmitting,
    isSubmitted,
    failure,
  ];
}
