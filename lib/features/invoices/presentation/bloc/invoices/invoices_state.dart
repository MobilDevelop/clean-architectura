part of 'invoices_bloc.dart';

final class InvoicesState extends Equatable {
  const InvoicesState({
    required this.query,
    required this.invoices,
    required this.isLoading,
    required this.isPageLoading,
    required this.isLast,
    required this.hasLoaded,
    required this.sendingId,
    required this.sentId,
    this.failure,
  });

  const InvoicesState.initial()
    : query = const InvoicesQuery.first(),
      invoices = const <Invoice>[],
      isLoading = false,
      isPageLoading = false,
      isLast = false,
      hasLoaded = false,
      sendingId = 0,
      sentId = 0,
      failure = null;

  final InvoicesQuery query;
  final List<Invoice> invoices;

  /// Birinchi sahifa yuklanmoqda — skelet shu paytda chiziladi.
  final bool isLoading;

  /// Keyingi sahifa yuklanmoqda — ro'yxat ekranda qoladi.
  final bool isPageLoading;

  final bool isLast;

  /// Kamida bir marta javob kelgan. Bo'sh ro'yxatni «hali so'ralmagan» dan
  /// ajratish uchun.
  final bool hasLoaded;

  /// Hozir yuborilayotgan faktura. `0` — hech qaysi.
  ///
  /// Nega id: aylanish belgisi aynan bosilgan kartada turishi kerak, umumiy
  /// bayroq bo'lsa u butun ro'yxatda ko'rinardi.
  final int sendingId;

  /// Oxirgi yuborilgan faktura. Har bir yangi urinish boshida `0` ga
  /// qaytadi, shuning uchun ekran har safar bir marta xabar beradi.
  final int sentId;

  final Failure? failure;

  bool get isEmpty => hasLoaded && invoices.isEmpty;

  InvoicesState copyWith({
    InvoicesQuery? query,
    List<Invoice>? invoices,
    bool? isLoading,
    bool? isPageLoading,
    bool? isLast,
    bool? hasLoaded,
    int? sendingId,
    int? sentId,
    Failure? failure,
    bool clearFailure = false,
  }) => InvoicesState(
    query: query ?? this.query,
    invoices: invoices ?? this.invoices,
    isLoading: isLoading ?? this.isLoading,
    isPageLoading: isPageLoading ?? this.isPageLoading,
    isLast: isLast ?? this.isLast,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    sendingId: sendingId ?? this.sendingId,
    sentId: sentId ?? this.sentId,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    query,
    invoices,
    isLoading,
    isPageLoading,
    isLast,
    hasLoaded,
    sendingId,
    sentId,
    failure,
  ];
}
