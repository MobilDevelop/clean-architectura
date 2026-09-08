part of 'contract_products_bloc.dart';

enum ProductWrite { none, adding, saving, removing }

final class ContractProductsState extends Equatable {
  const ContractProductsState({
    required this.args,
    required this.products,
    required this.isLoading,
    required this.write,
    required this.revision,
    this.contractId,
    this.busyProductId,
    this.failure,
  });

  ContractProductsState.initial(this.args)
    : contractId = args.contractId,
      products = const <ContractProduct>[],
      isLoading = false,
      write = ProductWrite.none,
      revision = 0,
      busyProductId = null,
      failure = null;

  final ContractCreateArgs args;

  /// Qoralama id si. Yangi shartnomada birinchi tovar qo'shilgach paydo bo'ladi.
  final int? contractId;

  final List<ContractProduct> products;
  final bool isLoading;
  final ProductWrite write;

  /// Qaysi qator ustida amal ketyapti. Yangi tovarda `null`.
  final int? busyProductId;

  /// Muvaffaqiyatli server yozuvlari soni. Har o'zgarishda ekran shartnomani
  /// qayta o'qiydi — yopishqoq bayroq ikkinchi o'zgarishda uyg'otmasdi.
  final int revision;

  final Failure? failure;

  bool get isBusy => write != ProductWrite.none;

  int get total => products.fold(0, (int sum, ContractProduct e) => sum + e.total);

  ContractProductsState copyWith({
    int? contractId,
    List<ContractProduct>? products,
    bool? isLoading,
    ProductWrite? write,
    int? busyProductId,
    int? revision,
    Failure? failure,
    bool clearFailure = false,
    bool clearBusyProduct = false,
  }) => ContractProductsState(
    args: args,
    contractId: contractId ?? this.contractId,
    products: products ?? this.products,
    isLoading: isLoading ?? this.isLoading,
    write: write ?? this.write,
    busyProductId: clearBusyProduct ? null : busyProductId ?? this.busyProductId,
    revision: revision ?? this.revision,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => <Object?>[
    args,
    contractId,
    products,
    isLoading,
    write,
    busyProductId,
    revision,
    failure,
  ];
}
