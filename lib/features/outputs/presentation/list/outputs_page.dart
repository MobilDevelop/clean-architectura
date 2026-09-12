import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/sheets/date_sheet.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/core/widgets/states/pull_refresh.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/outputs_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/shared/output_text.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/output_card.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/outputs_header.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/outputs_skeleton.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_sheet.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Taqvimda nechta yil orqaga qarash mumkin.
const int _yearSpan = 1;

/// Ro'yxat oxiriga shuncha qolganda keyingi sahifa so'raladi.
const double _loadAhead = 300;

final class OutputsPage extends StatefulWidget {
  const OutputsPage({super.key, required this.requirementsOpener});

  /// Qurilma talablari oynasini ochadi. Marshrut nomi sahifada turmasligi
  /// uchun tashqaridan beriladi (1.3).
  final Future<void> Function(BuildContext context, OutputContract contract) requirementsOpener;

  @override
  State<OutputsPage> createState() => _OutputsPageState();
}

final class _OutputsPageState extends State<OutputsPage> {
  final ScrollController _scroll = ScrollController();
  late final OutputsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<OutputsBloc>();
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

  /// Chiqim berish oqimi.
  ///
  /// Talab bajarilmagan bo'lsa oyna yopiladi, talablar sahifasi ochiladi va
  /// qaytilgach oyna qaytadan ochiladi — yangi oyna talabni qaytadan
  /// tekshiradi. Sahifani ochiq oynaning ustiga qo'yish `go_router` ning
  /// sahifalar ro'yxatini imperativ marshrut bilan aralashtirardi.
  ///
  /// Chiqim berilgach ro'yxat boshidan o'qiladi: berilgan shartnoma
  /// ro'yxatdan chiqib ketadi.
  Future<void> _openRelease(OutputContract contract) async {
    ReleaseOutcome outcome = await showReleaseSheet(context: context, contract: contract);

    while (outcome == ReleaseOutcome.requirementsNeeded) {
      if (!mounted) return;
      await widget.requirementsOpener(context, contract);

      if (!mounted) return;
      outcome = await showReleaseSheet(context: context, contract: contract);
    }

    if (!mounted || outcome != ReleaseOutcome.released) return;

    unawaited(CustomAnimatedToast.showSuccess(ReleaseText.done));
    _bloc.add(const OutputsRequested());
  }

  /// Qaytarish — qaytarib bo'lmaydigan amal, avval tasdiq so'raladi.
  ///
  /// Flex'da bu dialog yozilgan, lekin uni ochadigan hodisa hech qayerdan
  /// yuborilmagan: tovarlar tasdiqsiz qaytarilardi.
  Future<void> _confirmReturn(int count) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: AppIcons.delete,
        accent: AppTheme.colors.red,
        title: OutputText.returnTitle,
        message: OutputText.returnQuestion(count),
        actionLabel: OutputText.returnConfirm,
        cancelLabel: OutputText.returnCancel,
        onAction: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    if (!mounted || confirmed != true) return;

    _bloc.add(const ReturnRequested());
  }

  Future<void> _openFilter(DateTime? current) {
    final DateTime today = DateTime.now();

    return showDateSheet(
      context: context,
      title: OutputText.filter,
      subtitle: OutputText.filterSubtitle,
      date: current,
      firstDate: DateTime(today.year - _yearSpan, today.month, today.day),
      lastDate: today,
      onPicked: (DateTime date) => _bloc.add(DateSelected(date)),
      onClear: () => _bloc.add(const DateCleared()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: BlocSelector<OutputsBloc, OutputsState, Failure?>(
        selector: (OutputsState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const Retried()),
          bottomInset: ScreenSize.h80,
          child: BlocListener<OutputsBloc, OutputsState>(
            listenWhen: (OutputsState previous, OutputsState current) =>
                current.isReturned && !previous.isReturned,
            listener: (BuildContext context, OutputsState state) =>
                unawaited(CustomAnimatedToast.showSuccess(OutputText.returned)),
            child: Stack(
              children: <Widget>[
                const BackgroundWash(),

                Positioned.fill(
                  child: BlocBuilder<OutputsBloc, OutputsState>(
                    builder: (BuildContext context, OutputsState state) =>
                        PullRefresh<OutputsBloc, OutputsState>(
                          isLoading: (OutputsState state) => state.isLoading,
                          refreshPress: () => _bloc.add(const OutputsRequested()),
                          edgeOffset: topInset + ScreenSize.h56,
                          child: _content(state, topInset + ScreenSize.h56),
                        ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: BlocSelector<OutputsBloc, OutputsState, DateTime?>(
                    selector: (OutputsState state) => state.query.date,
                    builder: (BuildContext context, DateTime? date) => OutputsHeader(
                      topInset: topInset,
                      date: date,
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

  Widget _content(OutputsState state, double topPadding) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding + ScreenSize.h12, bottom: ScreenSize.h90);

    // Skelet faqat birinchi yuklashda: yangilashda ro'yxat ekranda qoladi.
    if (state.isLoading && state.contracts.isEmpty) {
      return ListView(
        controller: _scroll,
        padding: padding,
        children: const <Widget>[OutputsSkeleton()],
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
            icon: AppIcons.product,
            title: OutputText.emptyTitle,
            message: OutputText.emptyMessage,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scroll,
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      // Oxirgi o'rin sahifa yuklanishi uchun.
      itemCount: state.contracts.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == state.contracts.length) return _pageLoader(state);

        final OutputContract contract = state.contracts[index];

        final bool isOpen = state.openId == contract.id;

        return OutputCard(
          key: ValueKey<int>(contract.id),
          contract: contract,
          isOpen: isOpen,
          isLoading: state.isProductsLoading && isOpen,
          products: state.products[contract.id],
          selected: isOpen ? state.selected : const <int>{},
          isReturning: state.isReturning && isOpen,
          onTap: () => _bloc.add(ContractToggled(contract.id)),
          onProductTap: (int productId) => _bloc.add(ProductToggled(productId)),
          onRelease: () => unawaited(_openRelease(contract)),
          onReturn: () => unawaited(_confirmReturn(state.selected.length)),
        );
      },
    );
  }

  Widget _pageLoader(OutputsState state) {
    if (!state.isPageLoading) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h16),
      child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
    );
  }
}
