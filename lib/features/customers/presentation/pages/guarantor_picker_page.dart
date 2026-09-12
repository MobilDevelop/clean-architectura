import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers/customers_event.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers/customers_state.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/customer_search_formatter.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/customer_search_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customers_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  const GuarantorPickerPage({
    super.key,
    required this.verifyOpener,
    required this.newClientOpener,
    required this.formOpener,
  });

  /// Yuz tekshiruvi ekranini ochadi. Marshrutni router biladi (8.2).
  /// Mavjud mijozni tasdiqlaydi: oferta va yuz tekshiruvi.
  final Future<CustomerInfo?> Function(BuildContext context, CustomerInfo customer) verifyOpener;

  /// Yangi mijozni pasport bo'yicha topadi.
  final Future<CustomerInfo?> Function(BuildContext context) newClientOpener;

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
    // Shaxsni solishtirish tasdiqlash ekranining ichida — u kimni
    // tekshirayotganini biladi.
    final CustomerInfo? verified = await widget.verifyOpener(context, customer);
    if (verified == null || !mounted) return;

    _close(verified);
  }

  /// Yangi kafil: pasport → oferta → yuz → to'ldirish formasi.
  Future<void> _createNew() async {
    final CustomerInfo? verified = await widget.newClientOpener(context);
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

                    // Yon chetlar kartalarniki bilan bir xil (12): karta o'z
                    // `margin` ini o'zi qo'yadi, maydon esa qo'ymaydi.
                    Padding(
                      padding: EdgeInsets.fromLTRB(ScreenSize.h12, ScreenSize.h10, ScreenSize.h12, 0),
                      child: TextInputWidget(
                        // Qidiruv uch xil: `CustomerSearchParams` matnni
                        // pasport, INPS va ism-familiyaga ajratadi. Maydon
                        // faqat ikkitasini aytsa, uchinchisi yo'q deb
                        // o'ylanadi — matn qoidadan orqada qolgan edi.
                        hint: "F.I.O., pasport yoki INPS",
                        controller: _controller,
                        errorText: CustomerSearchIssueText.of(state.searchIssue),
                        // Asosiy qidiruv bilan bir xil: shakl bir joyda
                        // qo'yiladi, ikkinchisida esa yo'q bo'lsa bitta qoida
                        // ikki xil ishlab qolardi.
                        formatters: <TextInputFormatter>[
                          CustomerSearchFormatter(),
                          LengthLimitingTextInputFormatter(60),
                        ],
                        // Ism bo'yicha qidiruv faqat tasdiqlanganda ketadi
                        // (pasport va INPS to'lganda o'zi ketadi), shuning
                        // uchun klaviaturada "done" emas, qidiruv tugmasi
                        // turishi kerak — aks holda nima bosish kerakligi
                        // ko'rinmaydi.
                        textInputAction: TextInputAction.search,
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

  /// Karta va skelet o'z yon chetini o'zi qo'yadi (`margin: 12`). Ro'yxatga
  /// yana yon padding berilsa u ikki marta hisoblanadi: 393px ekranda karta
  /// 369 o'rniga 337 bo'lib qoladi, matn esa chetdan 42px da boshlanadi.
  /// Mijozlar ekrani shu sababli yon paddingsiz (`customer_page.dart:177`).
  EdgeInsets get _listPadding => EdgeInsets.only(top: ScreenSize.h12, bottom: ScreenSize.h24);

  Widget _list(CustomersState state) {
    if (state.isLoading) {
      return ListView(padding: _listPadding, children: const <Widget>[CustomersSkeleton()]);
    }

    return ListView(
      padding: _listPadding,
      children: <Widget>[
        for (final CustomerInfo item in state.customers)
          CustomerInfoWidget(info: item, pressActions: () => unawaited(_pickExisting(item))),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
          child: Column(
            children: <Widget>[
              // "Hali qidirilmagan" va "topilmadi" bir xil ko'rinmaydi: birinchisi
              // nima yozish kerakligini aytadi, ikkinchisi nima qilish kerakligini.
              if (state.customers.isEmpty) ...<Widget>[
                state.hasSearched
                    ? EmptyPlaceholder(
                        icon: AppIcons.person,
                        title: "Mijoz topilmadi",
                        message: "Yangi kafil sifatida qo'shishingiz mumkin",
                      )
                    : EmptyPlaceholder(
                        icon: AppIcons.search,
                        title: "Kafilni qidiring",
                        message: "Pasport seriyasi, INPS yoki ism-familiya bo'yicha qidirish mumkin",
                      ),
                Gap(ScreenSize.h12),
              ],

              _newButton(),
            ],
          ),
        ),
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
