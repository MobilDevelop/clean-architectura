import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/session/session_store.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/list_skeleton.dart';
import 'package:colloborator_v3/core/widgets/states/pull_refresh.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/bloc/customer_analysis_bloc.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_text.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/widgets/analysis_card.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/widgets/analysis_form.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/widgets/analysis_sms_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// «Mijoz tahlili» — drawerdan ochiladigan alohida ekran (`showPrescoring`
/// huquqi bo'lganda).
final class CustomerAnalysisPage extends StatefulWidget {
  const CustomerAnalysisPage({super.key});

  @override
  State<CustomerAnalysisPage> createState() => _CustomerAnalysisPageState();
}

final class _CustomerAnalysisPageState extends State<CustomerAnalysisPage> {
  late final CustomerAnalysisBloc _bloc;

  /// Karta orqali kengaytirilgan tahlil huquqi — `PermissionsDto.card`.
  late final bool _showCardAdd;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CustomerAnalysisBloc>();
    _showCardAdd = context.read<SessionStore>().user?.permissions.showScoringCard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: BlocSelector<CustomerAnalysisBloc, CustomerAnalysisState, Failure?>(
        selector: (CustomerAnalysisState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const Retried()),
          bottomInset: ScreenSize.h24,
          child: BlocListener<CustomerAnalysisBloc, CustomerAnalysisState>(
            listenWhen: (CustomerAnalysisState previous, CustomerAnalysisState current) =>
                current.submitted && !previous.submitted,
            listener: (BuildContext context, CustomerAnalysisState state) =>
                unawaited(CustomAnimatedToast.showSuccess(AnalysisText.submitted)),
            child: Stack(
              children: <Widget>[
                const BackgroundWash(),

                Positioned.fill(
                  child: BlocBuilder<CustomerAnalysisBloc, CustomerAnalysisState>(
                    builder: (BuildContext context, CustomerAnalysisState state) =>
                        PullRefresh<CustomerAnalysisBloc, CustomerAnalysisState>(
                          isLoading: (CustomerAnalysisState state) => state.isLoading,
                          refreshPress: () => _bloc.add(const AnalysisRequested()),
                          edgeOffset: topInset + ScreenSize.h56,
                          child: _content(state, topInset + ScreenSize.h56),
                        ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PageHeader(title: AnalysisText.title, topInset: topInset, backPress: context.pop),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(CustomerAnalysisState state, double topPadding) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding + ScreenSize.h4, bottom: ScreenSize.h24);

    final List<Widget> body;

    // Skelet faqat birinchi yuklashda: yangilashda ro'yxat ekranda qoladi.
    if (state.isLoading && !state.hasLoaded) {
      body = const <Widget>[ListSkeleton()];
    } else if (state.isEmpty) {
      body = const <Widget>[
        EmptyPlaceholder(icon: AppIcons.graphic, title: AnalysisText.emptyTitle, message: AnalysisText.emptyMessage),
      ];
    } else {
      body = state.items
          .map(
            (CustomerAnalysis item) => AnalysisCardTile(
              key: ValueKey<int>(item.id),
              item: item,
              isConfirming: state.confirmingId == item.id,
              onTap: item.status.needsSmsCode
                  ? () => unawaited(showAnalysisSmsSheet(context: context, item: item))
                  : null,
            ),
          )
          .toList();
    }

    return ListView(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      children: <Widget>[
        AnalysisForm(showCardAdd: _showCardAdd),

        Gap(ScreenSize.h4),
        ...body,
      ],
    );
  }
}
