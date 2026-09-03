import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/relative_kind.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_search_params.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_provinces_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_regions_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/get_villages_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/search_workplaces_usecase.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/update_customer_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'add_customer_event.dart';
part 'add_customer_state.dart';

final class AddCustomerBloc extends Bloc<AddCustomerEvent, AddCustomerState> {
  AddCustomerBloc({
    required CustomerInfo info,
    required bool isEdit,
    required this._getProvinces,
    required this._getRegions,
    required this._getVillages,
    required this._searchWorkplaces,
    required this._updateCustomer,
  }) : super(AddCustomerState.initial(info: info, isEdit: isEdit)) {
    on<AddCustomerStarted>(_started);
    // Tez almashtirilganda eski ro'yxat yangisini bosib ketmasligi uchun.
    on<ProvinceSelected>(_provinceSelected, transformer: restartable());
    on<RegionSelected>(_regionSelected, transformer: restartable());
    on<VillageSelected>(_villageSelected);
    on<WorkplaceSelected>(_workplaceSelected);

    // Har harfda so'rov ketmasligi uchun oldingisi bekor qilinadi.
    on<WorkplaceQueryChanged>(_workplaceQueryChanged, transformer: restartable());

    on<StreetChanged>(_streetChanged);
    on<HouseChanged>(_houseChanged);
    on<MainPhoneChanged>(_mainPhoneChanged);
    on<RelativePhoneChanged>(_relativePhoneChanged);
    on<RelativeKindSelected>(_relativeKindSelected);
    on<FriendPhoneChanged>(_friendPhoneChanged);
    on<FormSubmitted>(_formSubmitted);
    on<FailureHandled>(_failureHandled);
  }

  final GetProvincesUsecase _getProvinces;
  final GetRegionsUsecase _getRegions;
  final GetVillagesUsecase _getVillages;
  final SearchWorkplacesUsecase _searchWorkplaces;
  final UpdateCustomerUsecase _updateCustomer;

  static const Duration _typingPause = Duration(milliseconds: 350);

  Future<void> _started(AddCustomerStarted event, Emitter<AddCustomerState> emit) async {
    emit(state.copyWith(isCatalogLoading: true, clearFailure: true));

    final Result<List<Province>> result = await _getProvinces(const NoParams());

    switch (result) {
      case Ok(: final List<Province> value):
        emit(state.copyWith(isCatalogLoading: false, provinces: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isCatalogLoading: false, failure: failure));
        return;
    }

    // Tahrirlashda mijozning viloyati allaqachon tanlangan — ostki ro'yxatlar
    // ham darhol yuklanadi, aks holda agent ularni qayta tanlashga majbur.
    final Province? province = state.form.province;
    if (province != null) await _loadRegions(province.id, emit);

    final Region? region = state.form.region;
    if (region != null) await _loadVillages(region.id, emit);
  }

  Future<void> _provinceSelected(ProvinceSelected event, Emitter<AddCustomerState> emit) async {
    emit(
      state.copyWith(
        form: state.form.withProvince(event.value),
        issue: CustomerFormIssue.none,
        regions: const <Region>[],
        villages: const <Village>[],
        workplaces: const <WorkplaceInfo>[],
      ),
    );

    await _loadRegions(event.value.id, emit);
  }

  Future<void> _regionSelected(RegionSelected event, Emitter<AddCustomerState> emit) async {
    emit(
      state.copyWith(
        form: state.form.withRegion(event.value),
        issue: CustomerFormIssue.none,
        villages: const <Village>[],
        workplaces: const <WorkplaceInfo>[],
      ),
    );

    await _loadVillages(event.value.id, emit);
  }

  void _villageSelected(VillageSelected event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(village: event.value), issue: CustomerFormIssue.none));

  void _workplaceSelected(WorkplaceSelected event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(workplace: event.value), issue: CustomerFormIssue.none));

  Future<void> _workplaceQueryChanged(WorkplaceQueryChanged event, Emitter<AddCustomerState> emit) async {
    final Region? region = state.form.region;
    if (region == null) return;

    // `restartable` yangi harf kelganda shu kutishni bekor qiladi — har harfga
    // so'rov ketmaydi.
    await Future<void>.delayed(_typingPause);
    if (emit.isDone) return;

    emit(state.copyWith(isWorkplaceLoading: true, clearFailure: true));

    final Result<List<WorkplaceInfo>> result = await _searchWorkplaces(WorkplaceSearchParams(regionId: region.id, query: event.value));
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<WorkplaceInfo> value):
        emit(state.copyWith(isWorkplaceLoading: false, workplaces: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isWorkplaceLoading: false, failure: failure));
    }
  }

  void _streetChanged(StreetChanged event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(street: event.value), issue: CustomerFormIssue.none));

  void _houseChanged(HouseChanged event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(houseNumber: event.value), issue: CustomerFormIssue.none));

  void _mainPhoneChanged(MainPhoneChanged event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(mainPhone: event.value), issue: CustomerFormIssue.none));

  void _relativePhoneChanged(RelativePhoneChanged event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(relativePhone: event.value), issue: CustomerFormIssue.none));

  void _relativeKindSelected(RelativeKindSelected event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(relativeKind: event.value), issue: CustomerFormIssue.none));

  void _friendPhoneChanged(FriendPhoneChanged event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(form: state.form.copyWith(friendPhone: event.value), issue: CustomerFormIssue.none));

  Future<void> _formSubmitted(FormSubmitted event, Emitter<AddCustomerState> emit) async {
    final CustomerFormIssue issue = state.form.issue;

    if (issue != CustomerFormIssue.none) {
      emit(state.copyWith(issue: issue));
      return;
    }

    final CustomerUpdateParams? params = state.form.toParams(isEdit: state.isEdit);

    // `issue` `none` bo'lsa bu yo'lga tushilmaydi. Tushilsa — bizning
    // nosozligimiz, jimgina qolmasin.
    if (params == null) {
      emit(state.copyWith(failure: const UnknownFailure('Ma\'lumotni yuborib bo\'lmadi')));
      return;
    }

    emit(state.copyWith(isLoading: true, clearFailure: true));

    final Result<void> result = await _updateCustomer(params);

    switch (result) {
      case Ok():
        emit(state.copyWith(isLoading: false, isSaved: true));
      case Err(: final Failure failure):
        emit(state.copyWith(isLoading: false, failure: failure));
    }
  }

  void _failureHandled(FailureHandled event, Emitter<AddCustomerState> emit) =>
      emit(state.copyWith(clearFailure: true));

  Future<void> _loadRegions(int provinceId, Emitter<AddCustomerState> emit) async {
    emit(state.copyWith(isCatalogLoading: true));

    final Result<List<Region>> result = await _getRegions(provinceId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<Region> value):
        emit(state.copyWith(isCatalogLoading: false, regions: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isCatalogLoading: false, failure: failure));
    }
  }

  Future<void> _loadVillages(int regionId, Emitter<AddCustomerState> emit) async {
    emit(state.copyWith(isCatalogLoading: true));

    final Result<List<Village>> result = await _getVillages(regionId);
    if (emit.isDone) return;

    switch (result) {
      case Ok(: final List<Village> value):
        emit(state.copyWith(isCatalogLoading: false, villages: value));
      case Err(: final Failure failure):
        emit(state.copyWith(isCatalogLoading: false, failure: failure));
    }
  }
}
