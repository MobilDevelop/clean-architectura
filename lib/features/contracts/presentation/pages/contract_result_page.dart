import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_tab.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/mib_tab.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_tab_bar.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/scoring_tab.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Tablar tartibi: 0 — Skoring, 1 — MIB, 2 — KATM.
const int _mibTab = 1;
const int _katmTab = 2;

final class ContractResultPage extends StatefulWidget {
  const ContractResultPage({super.key});

  @override
  State<ContractResultPage> createState() => _ContractResultPageState();
}

final class _ContractResultPageState extends State<ContractResultPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final ContractResultBloc _bloc;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _bloc = context.read<ContractResultBloc>();

    // Kredit hisobotlari og'ir so'rov: faqat tab ochilganda so'raladi.
    _tabs.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.indexIsChanging) return;

    // Ketma-ketlik bloc'da: ishtirokchilar kelmasdan KATM so'ralmaydi.
    if (_tabs.index == _mibTab) _bloc.add(const MibOpened());
    if (_tabs.index == _katmTab) _bloc.add(const KatmOpened());
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final ContractResultBloc bloc = _bloc;

    return BlocSelector<ContractResultBloc, ContractResultState, Failure?>(
      selector: (ContractResultState state) => state.scoringFailure,
      builder: (BuildContext context, Failure? failure) => FailureView(
        failure: failure,
        onHandled: () => bloc.add(const ScoringFailureHandled()),
        onRetry: () => bloc.add(const ScoringRequested()),
        child: Scaffold(
          backgroundColor: AppTheme.colors.backcolor,
          body: Column(
            children: <Widget>[
              PageHeader(title: "Skoring natijalari", topInset: topInset, backPress: context.pop),

              ResultTabBar(controller: _tabs),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: const <Widget>[ScoringTab(), MibTab(), KatmTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
