import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/relative_kind.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/add_customer_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/customer_form_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/address_section.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_summary_card.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/form_section.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/phones_section.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/pick_sheet.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/select_tile.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/workplace_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

final class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key, required this.isEdit});

  final bool isEdit;

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

final class _AddCustomerPageState extends State<AddCustomerPage> {
  late final TextEditingController _street;
  late final TextEditingController _house;
  late final TextEditingController _mainPhone;
  late final TextEditingController _relativePhone;
  late final TextEditingController _friendPhone;
  late final AddCustomerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AddCustomerBloc>();

    final CustomerForm form = _bloc.state.form;
    _street = TextEditingController(text: form.street);
    _house = TextEditingController(text: form.houseNumber);
    // Serverdan raqam `+998901234567` ko'rinishida keladi; formatter faqat
    // tugma bosilganda ishlaydi, shuning uchun shakl shu yerda beriladi.
    _mainPhone = TextEditingController(text: PhoneFormatter.mask(form.mainPhone));
    _relativePhone = TextEditingController(text: PhoneFormatter.mask(form.relativePhone));
    _friendPhone = TextEditingController(text: PhoneFormatter.mask(form.friendPhone));
  }

  @override
  void dispose() {
    _street.dispose();
    _house.dispose();
    _mainPhone.dispose();
    _relativePhone.dispose();
    _friendPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return BlocListener<AddCustomerBloc, AddCustomerState>(
      listenWhen: (AddCustomerState previous, AddCustomerState current) => current.isSaved && !previous.isSaved,
      listener: (BuildContext context, AddCustomerState state) => context.pop(true),
      child: BlocSelector<AddCustomerBloc, AddCustomerState, Failure?>(
        selector: (AddCustomerState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          // Oxirgi bajarilmagan amal takrorlanadi: saqlash bo'lsa saqlash,
          // aks holda ma'lumotnomani qayta yuklash.
          onRetry: _retry,
          bottomInset: ScreenSize.h90,
          child: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            body: Stack(
              children: <Widget>[
                const BackgroundWash(),

                Positioned.fill(
                  child: BlocBuilder<AddCustomerBloc, AddCustomerState>(
                    builder: (BuildContext context, AddCustomerState state) => _form(state, topInset),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PageHeader(title: widget.isEdit ? "Ma'lumotni tahrirlash" : "Yangi mijoz", topInset: topInset, backPress: context.pop),
                ),
              ],
            ),

            bottomNavigationBar: SafeArea(
              minimum: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h12),
              child: BlocSelector<AddCustomerBloc, AddCustomerState, bool>(
                selector: (AddCustomerState state) => state.isLoading,
                builder: (BuildContext context, bool isLoading) => MainButton(
                  text: "Saqlash",
                  showLoading: isLoading,
                  onPressed: () => _bloc.add(const FormSubmitted()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(AddCustomerState state, double topInset) {
    final CustomerForm form = state.form;
    final CustomerFormIssue issue = state.issue;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset + ScreenSize.h56 + ScreenSize.h14,
        left: ScreenSize.h14,
        right: ScreenSize.h14,
        bottom: ScreenSize.h40,
      ),
      child: Column(
        children: <Widget>[
          CustomerSummaryCard(info: state.customer),

          FormSection(
            title: "Manzil",
            icon: AppIcons.info,
            child: AddressSection(
              form: form,
              issue: issue,
              streetController: _street,
              houseController: _house,
              pickProvince: () => unawaited(_pickProvince()),
              pickRegion: () => unawaited(_pickRegion()),
              pickVillage: () => unawaited(_pickVillage()),
              onStreetChanged: (String value) => _bloc.add(StreetChanged(value)),
              onHouseChanged: (String value) => _bloc.add(HouseChanged(value)),
            ),
          ),

          FormSection(
            title: "Telefon raqamlar",
            icon: AppIcons.phone,
            child: PhonesSection(
              form: form,
              issue: issue,
              mainController: _mainPhone,
              relativeController: _relativePhone,
              friendController: _friendPhone,
              onMainChanged: (String value) => _bloc.add(MainPhoneChanged(value)),
              onRelativeChanged: (String value) => _bloc.add(RelativePhoneChanged(value)),
              onFriendChanged: (String value) => _bloc.add(FriendPhoneChanged(value)),
              pickRelativeKind: () => unawaited(_pickRelativeKind()),
            ),
          ),

          FormSection(
            title: "Ish joyi",
            icon: AppIcons.workplace,
            child: SelectTile(
              title: "Tashkilot",
              hint: form.region == null ? "Avval tumanni tanlang" : "Tanlang",
              value: form.workplace?.name ?? '',
              // Faoliyat turi tanlovni aniqlashtiradi: bir xil nomli tashkilot ko'p.
              subtitle: form.workplace?.category.name,
              errorText: CustomerFormIssueText.workplace(issue),
              enabled: form.region != null,
              onTap: () => unawaited(_pickWorkplace()),
            ),
          ),
        ],
      ),
    );
  }

  void _retry() {
    if (_bloc.state.provinces.isEmpty) {
      _bloc.add(const AddCustomerStarted());
      return;
    }

    _bloc.add(const FormSubmitted());
  }

  Future<void> _pickProvince() => showPickSheet<Province>(
    context: context,
    title: "Viloyat",
    items: _bloc.state.provinces,
    selected: _bloc.state.form.province,
    isLoading: _bloc.state.isCatalogLoading,
    labelOf: (Province item) => item.title,
    onPicked: (Province item) => _bloc.add(ProvinceSelected(item)),
  );

  Future<void> _pickRegion() => showPickSheet<Region>(
    context: context,
    title: "Tuman",
    items: _bloc.state.regions,
    selected: _bloc.state.form.region,
    isLoading: _bloc.state.isCatalogLoading,
    labelOf: (Region item) => item.title,
    onPicked: (Region item) => _bloc.add(RegionSelected(item)),
  );

  Future<void> _pickVillage() => showPickSheet<Village>(
    context: context,
    title: "Mahalla",
    items: _bloc.state.villages,
    selected: _bloc.state.form.village,
    isLoading: _bloc.state.isCatalogLoading,
    labelOf: (Village item) => item.title,
    onPicked: (Village item) => _bloc.add(VillageSelected(item)),
  );

  Future<void> _pickRelativeKind() => showPickSheet<RelativeKind>(
    context: context,
    title: "Kim bo'ladi",
    items: RelativeKind.values,
    selected: _bloc.state.form.relativeKind,
    labelOf: (RelativeKind item) => item.title,
    onPicked: (RelativeKind item) => _bloc.add(RelativeKindSelected(item)),
  );

  /// Ish joyi serverda qidiriladi, shuning uchun oynaga bloc kerak.
  Future<void> _pickWorkplace() => showAppSheet(
    context: context,
    child: BlocProvider<AddCustomerBloc>.value(
      value: _bloc,
      child: WorkplaceSheet(
        selected: _bloc.state.form.workplace,
        onPicked: (WorkplaceInfo item) => _bloc.add(WorkplaceSelected(item)),
      ),
    ),
  );
}
