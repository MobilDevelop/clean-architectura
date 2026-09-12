import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/external_file.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/drawer/app_drawer_scope.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/date_filter_header.dart';
import 'package:colloborator_v3/core/widgets/sheets/date_sheet.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/list_skeleton.dart';
import 'package:colloborator_v3/core/widgets/states/pull_refresh.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices/invoices_bloc.dart';
import 'package:colloborator_v3/features/invoices/presentation/styles/invoice_text.dart';
import 'package:colloborator_v3/features/invoices/presentation/widgets/invoice_actions_sheet.dart';
import 'package:colloborator_v3/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Taqvimda nechta yil orqaga qarash mumkin.
const int _yearSpan = 1;

/// Ro'yxat oxiriga shuncha qolganda keyingi sahifa so'raladi.
const double _loadAhead = 300;

final class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

final class _InvoicesPageState extends State<InvoicesPage> {
  final ScrollController _scroll = ScrollController();
  late final InvoicesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<InvoicesBloc>();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  /// Ro'yxat oxiriga yaqinlashganda keyingi sahifa. Takroriy so'rovni bloc
  /// o'zi to'sadi (`droppable` va `isLast`).
  void _onScroll() {
    if (!_scroll.hasClients) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - _loadAhead) return;

    _bloc.add(const NextPageRequested());
  }

  Future<void> _openFilter(DateTime? current) {
    final DateTime today = DateTime.now();

    return showDateSheet(
      context: context,
      title: InvoiceText.filter,
      subtitle: InvoiceText.filterSubtitle,
      date: current,
      firstDate: DateTime(today.year - _yearSpan, today.month, today.day),
      lastDate: today,
      onPicked: (DateTime date) => _bloc.add(DateSelected(date)),
      onClear: () => _bloc.add(const DateCleared()),
    );
  }

  /// Faktura fayli tashqi ilovada ochiladi.
  ///
  /// Nega ilovaning ichida emas: fayl PDF va uni ilova ichida ko'rsatish
  /// uchun alohida kutubxona kerak bo'lardi. Natija tekshiriladi — ochadigan
  /// ilova bo'lmasa bosish jimgina yo'qolardi (5.8).
  Future<void> _open(Invoice invoice) async {
    if (await ExternalFile.open(invoice.waybillUrl)) return;

    await CustomAnimatedToast.showInfo(InvoiceText.openFailed);
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: BlocSelector<InvoicesBloc, InvoicesState, Failure?>(
        selector: (InvoicesState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const Retried()),
          bottomInset: ScreenSize.h80,
          child: BlocListener<InvoicesBloc, InvoicesState>(
            listenWhen: (InvoicesState previous, InvoicesState current) =>
                current.sentId != 0 && current.sentId != previous.sentId,
            listener: (BuildContext context, InvoicesState state) =>
                unawaited(CustomAnimatedToast.showSuccess(InvoiceText.sent)),
            child: Stack(
              children: <Widget>[
                const BackgroundWash(),

                Positioned.fill(
                  child: BlocBuilder<InvoicesBloc, InvoicesState>(
                    builder: (BuildContext context, InvoicesState state) =>
                        PullRefresh<InvoicesBloc, InvoicesState>(
                          isLoading: (InvoicesState state) => state.isLoading,
                          refreshPress: () => _bloc.add(const InvoicesRequested()),
                          edgeOffset: topInset + ScreenSize.h56,
                          child: _content(state, topInset + ScreenSize.h56),
                        ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: BlocSelector<InvoicesBloc, InvoicesState, DateTime?>(
                    selector: (InvoicesState state) => state.query.date,
                    builder: (BuildContext context, DateTime? date) => DateFilterHeader(
                      title: InvoiceText.title,
                      topInset: topInset,
                      date: date,
                      drawerPress: () => AppDrawerScope.of(context)?.call(),
                      filterPress: () => unawaited(_openFilter(date)),
                      clearDate: () => _bloc.add(const DateCleared()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(InvoicesState state, double topPadding) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding + ScreenSize.h12, bottom: ScreenSize.h90);

    // Skelet faqat birinchi yuklashda: yangilashda ro'yxat ekranda qoladi.
    if (state.isLoading && state.invoices.isEmpty) {
      return ListView(
        controller: _scroll,
        padding: padding,
        children: const <Widget>[ListSkeleton()],
      );
    }

    if (state.isEmpty) {
      return ListView(
        controller: _scroll,
        padding: padding,
        // Bo'sh ro'yxatni ham tortib yangilash mumkin.
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          EmptyPlaceholder(
            icon: AppIcons.contract,
            title: InvoiceText.emptyTitle,
            message: InvoiceText.emptyMessage,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      // Oxirgi o'rin sahifa yuklanishi uchun.
      itemCount: state.invoices.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == state.invoices.length) return _pageLoader(state);

        final Invoice invoice = state.invoices[index];

        return InvoiceCard(
          key: ValueKey<int>(invoice.id),
          invoice: invoice,
          isSending: state.sendingId == invoice.id,
          onTap: () => unawaited(
            showInvoiceActionsSheet(
              context: context,
              invoice: invoice,
              onOpen: () => unawaited(_open(invoice)),
              onSend: () => _bloc.add(SendRequested(invoice)),
            ),
          ),
        );
      },
    );
  }

  Widget _pageLoader(InvoicesState state) {
    if (!state.isPageLoading) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
      child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
    );
  }
}
