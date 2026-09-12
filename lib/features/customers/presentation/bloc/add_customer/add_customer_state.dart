part of 'add_customer_bloc.dart';

final class AddCustomerState extends Equatable {
  const AddCustomerState({
    required this.customer,
    required this.form,
    required this.issue,
    required this.isEdit,
    required this.isLoading,
    required this.isCatalogLoading,
    required this.isSaved,
    required this.provinces,
    required this.regions,
    required this.villages,
    required this.workplaces,
    required this.isWorkplaceLoading,
    this.failure,
  });

  AddCustomerState.initial({required CustomerInfo info, required this.isEdit})
    : customer = info,
      form = CustomerForm.of(info),
      issue = CustomerFormIssue.none,
      isLoading = false,
      isCatalogLoading = false,
      isSaved = false,
      provinces = const <Province>[],
      regions = const <Region>[],
      villages = const <Village>[],
      workplaces = const <WorkplaceInfo>[],
      isWorkplaceLoading = false,
      failure = null;

  /// Yuz tekshiruvidan kelgan mijoz — sarlavha kartasi shundan chiziladi.
  final CustomerInfo customer;

  final CustomerForm form;
  final CustomerFormIssue issue;

  /// Mavjud mijoz tahrirlanyaptimi. So'rovda `is_edit` shundan ketadi.
  final bool isEdit;

  /// Saqlash so'rovi ketyapti — tugma shundan aylanadi.
  final bool isLoading;

  /// Ma'lumotnoma yuklanyapti (viloyat, tuman, mahalla).
  final bool isCatalogLoading;

  /// Saqlandi — sahifa orqaga qaytadi.
  final bool isSaved;

  final List<Province> provinces;
  final List<Region> regions;
  final List<Village> villages;
  final List<WorkplaceInfo> workplaces;
  final bool isWorkplaceLoading;

  final Failure? failure;

  AddCustomerState copyWith({
    CustomerForm? form,
    CustomerFormIssue? issue,
    bool? isLoading,
    bool? isCatalogLoading,
    bool? isSaved,
    List<Province>? provinces,
    List<Region>? regions,
    List<Village>? villages,
    List<WorkplaceInfo>? workplaces,
    bool? isWorkplaceLoading,
    Failure? failure,
    bool clearFailure = false,
  }) => AddCustomerState(
    customer: customer,
    form: form ?? this.form,
    issue: issue ?? this.issue,
    isEdit: isEdit,
    isLoading: isLoading ?? this.isLoading,
    isCatalogLoading: isCatalogLoading ?? this.isCatalogLoading,
    isSaved: isSaved ?? this.isSaved,
    provinces: provinces ?? this.provinces,
    regions: regions ?? this.regions,
    villages: villages ?? this.villages,
    workplaces: workplaces ?? this.workplaces,
    isWorkplaceLoading: isWorkplaceLoading ?? this.isWorkplaceLoading,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    customer,
    form,
    issue,
    isEdit,
    isLoading,
    isCatalogLoading,
    isSaved,
    provinces,
    regions,
    villages,
    workplaces,
    isWorkplaceLoading,
    failure,
  ];
}
