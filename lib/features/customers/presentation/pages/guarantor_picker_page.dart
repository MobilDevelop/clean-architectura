import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_event.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_state.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/face_id_page.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/customer_search_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customers_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Kafil sifatida qaytariladigan natija. Faqat oddiy tiplar —
/// `contract_create` bu featureni import qilmaydi (1.3).
typedef GuarantorPick = ({int clientId, String fullName, String passport});

/// Kafil tanlash: mavjud mijozni qidirish yoki yangisini yaratish.
///
/// Ikkala yo'l ham yuz tekshiruvidan o'tadi — flex'dagi qoida saqlangan.
/// Ro'yxatdan tanlangan mijozning pasporti yuz tekshiruvi ekraniga oldindan
/// to'ldirib beriladi.
final class GuarantorPickerPage extends StatefulWidget {
  const GuarantorPickerPage({super.key, required this.faceCheckOpener, required this.formOpener});

  /// Yuz tekshiruvi ekranini ochadi. Marshrutni router biladi (8.2).
  final Future<CustomerInfo?> Function(BuildContext context, FaceIdPrefill? prefill) faceCheckOpener;

  /// Yangi mijozning ma'lumotini to'ldirish ekrani.
  final Future<bool?> Function(BuildContext context, CustomerInfo customer) formOpener;

  @override
  State<GuarantorPickerPage> createState() => _GuarantorPickerPageState();
}

final class _GuarantorPickerPageState extends State<GuarantorPickerPage> {
  late final TextEditingController _controller;
  late final CustomersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _bloc = context.read<CustomersBloc>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mavjud mijoz: pasporti oldindan to'ldirilgan yuz tekshiruvi.
  Future<void> _pickExisting(CustomerInfo customer) async {
    final CustomerInfo? verified = await widget.faceCheckOpener(context, faceIdPrefillOf(customer));
    if (verified == null || !mounted) return;

    // Yuz boshqa mijozniki bo'lsa, kafil ham boshqa odam bo'lib qolardi.
    if (verified.id != customer.id) {
      await CustomAnimatedToast.showError("Yuz tekshiruvi bu mijozga mos kelmadi");
      return;
    }

    if (!mounted) return;

    _close(verified);
  }

  /// Yangi kafil: pasport → oferta → yuz → to'ldirish formasi.
  Future<void> _createNew() async {
    final CustomerInfo? verified = await widget.faceCheckOpener(context, null);
    if (verified == null || !mounted) return;

    final bool? saved = await widget.formOpener(context, verified);
    if (!(saved ?? false) || !mounted) return;

    _close(verified);
  }

  void _close(CustomerInfo customer) => context.pop<GuarantorPick>((
    clientId: customer.id,
    fullName: customer.fullName,
    passport: customer.passportNumber,
  ));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersBloc, CustomersState>(
      builder: (BuildContext context, CustomersState state) => FailureView(
        failure: state.failure,
        onHandled: () => _bloc.add(const FailureHandled()),
        onRetry: () => _bloc.add(const CustomersRefreshed()),
        child: Scaffold(
          backgroundColor: AppTheme.colors.backcolor,
          body: Stack(
            children: <Widget>[
              const BackgroundWash(),

              Positioned.fill(
                child: Column(
                  children: <Widget>[
                    PageHeader(
                      title: "Kafil tanlash",
                      topInset: MediaQuery.paddingOf(context).top,
                      backPress: () => context.pop(),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h12, ScreenSize.h16, 0),
                      child: TextInputWidget(
                        hint: "Pasport yoki JSHSHIR",
                        controller: _controller,
                        errorText: CustomerSearchIssueText.of(state.searchIssue),
                        onChanged: (String value) => _bloc.add(SearchQueryChanged(value)),
                        onSubmitted: (_) => _bloc.add(const SearchSubmitted()),
                      ),
                    ),

                    Expanded(child: _list(state)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Yangi kafil yaratish yo'li har doim ochiq: qidiruvda topilmagan
        // odam ham kafil bo'la oladi.
      ),
    );
  }

  Widget _list(CustomersState state) {
    if (state.isLoading) {
      return ListView(
        padding: EdgeInsets.all(ScreenSize.h16),
        children: const <Widget>[CustomersSkeleton()],
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h12, ScreenSize.h16, ScreenSize.h24),
      children: <Widget>[
        for (final CustomerInfo item in state.customers)
          CustomerInfoWidget(info: item, pressActions: () => unawaited(_pickExisting(item))),

        if (state.customers.isEmpty && state.hasSearched) ...<Widget>[
          EmptyPlaceholder(
            icon: AppIcons.person,
            title: "Mijoz topilmadi",
            message: "Yangi kafil sifatida qo'shishingiz mumkin",
          ),
          Gap(ScreenSize.h12),
        ],

        _newButton(),
      ],
    );
  }

  Widget _newButton() => InkWell(
    onTap: () => unawaited(_createNew()),
    borderRadius: BorderRadius.circular(ScreenSize.r18),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
      decoration: BoxDecoration(
        color: AppTheme.colors.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.person_add_alt_1_outlined, size: ScreenSize.h20, color: AppTheme.colors.primary),
          Gap(ScreenSize.w6),
          Text(
            "Yangi kafil qo'shish",
            style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
          ),
        ],
      ),
    ),
  );
}
