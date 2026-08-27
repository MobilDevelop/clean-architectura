import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_event.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_state.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_action_sheet.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_info.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customers_header.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/results_header.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customers_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ro'yxatning birinchi o'rni sarlavhaga ketadi.
const int _headerSlot = 1;

final class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

final class _CustomerPageState extends State<CustomerPage> {
  late final TextEditingController _searchController;
  late final CustomersBloc _bloc;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = context.read<CustomersBloc>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: BlocSelector<CustomersBloc, CustomersState, Failure?>(
        selector: (CustomersState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const SearchSubmitted()),
          // Banner "Mijoz qo'shish" tugmasi ustida turadi.
          bottomInset: ScreenSize.h60,
          child: BlocSelector<CustomersBloc, CustomersState, bool>(
            selector: (CustomersState state) => state.showSearch,
            builder: (BuildContext context, bool showSearch) => Stack(
              children: <Widget>[
                const BackgroundWash(),

                // Ro'yxat header ostidan suzib o'tadi — shuning uchun tepadagi
                // bo'shliq header balandligiga teng qilib berilyapti.
                Positioned.fill(
                  child: BlocSelector<CustomersBloc, CustomersState, ({bool isLoading, List<CustomerInfo> customers})>(
                    selector: (CustomersState state) => (isLoading: state.isLoading, customers: state.customers),
                    builder: (BuildContext context, ({bool isLoading, List<CustomerInfo> customers}) data) => _content(
                      data: data,
                      topPadding: topInset + ScreenSize.h56 + (showSearch ? ScreenSize.h76 : 0),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: CustomersHeader(
                    topInset: topInset,
                    showSearch: showSearch,
                    // Kiritish xatosi uchun state'da maydon yo'q: `searchError`
                    // olib tashlangan, shuning uchun bu yerda ko'rsatadigan
                    // narsa qolmadi (7.5 buzilgan).
                    searchError: '',
                    controller: _searchController,
                    drawerPress: () {},
                    searchPress: () => _bloc.add(const ShowSearch()),
                    onChanged: (String value) => _bloc.add(SearchQueryChanged(value)),
                    onSubmitted: (String _) => _bloc.add(const SearchSubmitted()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

        floatingActionButton: BlocSelector<CustomersBloc, CustomersState, bool>(
          selector: (CustomersState state) => state.customers.length < 2,
          builder: (BuildContext context, bool isFullSize) => FloatingActionButton.extended(
            onPressed: () {},
            isExtended: isFullSize,
            backgroundColor: AppTheme.colors.primary,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ScreenSize.r18)),
            extendedPadding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
            icon: Icon(Icons.add_rounded, color: AppTheme.colors.white, size: ScreenSize.h22),
            label: Text(
              "Mijoz qo'shish",
              style: AppTheme.data.textTheme.titleMedium?.copyWith(
                color: AppTheme.colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
        ),
      ),
    );
  }

  /// Holatga qarab nima ko'rsatilishini sahifa hal qiladi, widgetlar emas.
  Widget _content({
    required ({bool isLoading, List<CustomerInfo> customers}) data,
    required double topPadding,
  }) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding, bottom: ScreenSize.h90);

    if (data.isLoading) {
      return ListView(padding: padding, children: const <Widget>[CustomersSkeleton()]);
    }

    if (data.customers.isEmpty) {
      return ListView(
        padding: padding,
        physics: NeverScrollableScrollPhysics(),
        children: const <Widget>[
          EmptyPlaceholder(
            icon: AppIcons.search,
            title: "Mijozni qidiring",
            message: "Pasport seriyasi, INPS yoki ism-familiya bo'yicha qidirish mumkin",
          ),
        ],
      );
    }

    return ListView.builder(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: data.customers.length + _headerSlot,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return ResultsHeader(count: data.customers.length);

        final CustomerInfo customer = data.customers[index - _headerSlot];
        return CustomerInfoWidget(
          // Nega kalit: ro'yxat almashganda Flutter elementlarni o'rni bo'yicha
          // qayta ishlatadi. `id` bo'lsa, har karta o'z ma'lumotiga bog'lanadi.
          key: ValueKey<int>(customer.id),
          info: customer,
          pressActions: () => unawaited(
            showCustomerActions(
              context: context,
              info: customer,
              pressScoring: () {},
              pressContract: () {},
              pressEdit: () {},
              pressInfo: () {},
            ),
          ),
        );
      },
    );
  }
}