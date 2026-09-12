part of 'outputs_bloc.dart';

final class OutputsState extends Equatable {
  const OutputsState({
    required this.query,
    required this.contracts,
    required this.isLoading,
    required this.isPageLoading,
    required this.isLast,
    required this.hasLoaded,
    required this.openId,
    required this.products,
    required this.isProductsLoading,
    required this.selected,
    required this.isReturning,
    required this.isReturned,
    this.failure,
  });

  const OutputsState.initial()
    : query = const OutputsQuery.first(),
      contracts = const <OutputContract>[],
      isLoading = false,
      isPageLoading = false,
      isLast = false,
      hasLoaded = false,
      openId = 0,
      products = const <int, List<OutputProduct>>{},
      isProductsLoading = false,
      selected = const <int>{},
      isReturning = false,
      isReturned = false,
      failure = null;

  final OutputsQuery query;
  final List<OutputContract> contracts;

  /// Birinchi sahifa yuklanmoqda — skelet shu paytda chiziladi.
  final bool isLoading;

  /// Keyingi sahifa yuklanmoqda — ro'yxat ekranda qoladi.
  final bool isPageLoading;

  final bool isLast;

  /// Kamida bir marta javob kelgan. Bo'sh ro'yxatni «hali so'ralmagan» dan
  /// ajratish uchun.
  final bool hasLoaded;

  /// Ochiq turgan shartnoma. `0` — hammasi yopiq.
  final int openId;

  /// Shartnoma bo'yicha o'qilgan tovarlar.
  ///
  /// Nega saqlanadi: qator ikkinchi marta ochilganda so'rov takrorlanmaydi.
  /// Tovarlar chiqim berilgunicha o'zgarmaydi.
  final Map<int, List<OutputProduct>> products;

  final bool isProductsLoading;

  /// Qaytarish uchun belgilangan tovarlar — ochiq shartnomaniki.
  ///
  /// Nega state'da, entityda emas: belgilash ekranning holati, serverdan
  /// kelgan ma'lumot emas. Flex uni `OutputProducts.selected` deb modelning
  /// ichiga qo'ygan va model qayta o'qilganda belgilar bilan birga
  /// yo'qolardi.
  final Set<int> selected;

  final bool isReturning;

  /// Oxirgi qaytarish muvaffaqiyatli tugadi — ekran xabar beradi.
  ///
  /// Har bir yangi urinish boshida `false` ga qaytadi, shuning uchun ekran
  /// `false → true` o'tishini kutib har safar bir marta xabar beradi.
  /// Ro'yxat yangilanganda tozalanmaydi: qaytarishdan keyin ro'yxat darhol
  /// o'qiladi va bayroq o'sha yerda so'nib, xabar ko'rinmay qolardi.
  final bool isReturned;

  final Failure? failure;

  bool get isEmpty => hasLoaded && contracts.isEmpty;

  OutputsState copyWith({
    OutputsQuery? query,
    List<OutputContract>? contracts,
    bool? isLoading,
    bool? isPageLoading,
    bool? isLast,
    bool? hasLoaded,
    int? openId,
    Map<int, List<OutputProduct>>? products,
    bool? isProductsLoading,
    Set<int>? selected,
    bool? isReturning,
    bool? isReturned,
    Failure? failure,
    bool clearFailure = false,
  }) => OutputsState(
    query: query ?? this.query,
    contracts: contracts ?? this.contracts,
    isLoading: isLoading ?? this.isLoading,
    isPageLoading: isPageLoading ?? this.isPageLoading,
    isLast: isLast ?? this.isLast,
    hasLoaded: hasLoaded ?? this.hasLoaded,
    openId: openId ?? this.openId,
    products: products ?? this.products,
    isProductsLoading: isProductsLoading ?? this.isProductsLoading,
    selected: selected ?? this.selected,
    isReturning: isReturning ?? this.isReturning,
    isReturned: isReturned ?? this.isReturned,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    query,
    contracts,
    isLoading,
    isPageLoading,
    isLast,
    hasLoaded,
    openId,
    products,
    isProductsLoading,
    selected,
    isReturning,
    isReturned,
    failure,
  ];
}
