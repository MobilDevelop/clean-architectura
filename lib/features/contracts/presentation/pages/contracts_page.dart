import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/results_header.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_state.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_action_sheet.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contracts_filter_sheet.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contracts_header.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contracts_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Ro'yxatning birinchi o'rni sarlavhaga ketadi.
const int _headerSlot = 1;

final class ContractsPage extends StatefulWidget {
  const ContractsPage({super.key});

  @override
  State<ContractsPage> createState() => _ContractsPageState();
}

final class _ContractsPageState extends State<ContractsPage> {
  late final ContractsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ContractsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return BlocListener<ContractsBloc, ContractsState>(
      listenWhen: (ContractsState previous, ContractsState current) => current.errorMessage.isNotEmpty,
      listener: (BuildContext context, ContractsState state) {
        unawaited(CustomAnimatedToast.showInfo(state.errorMessage));
        _bloc.add(const ErrorShown());
      },
      child: Scaffold(
        backgroundColor: AppTheme.colors.backcolor,
        body: Stack(
          children: <Widget>[
            const BackgroundWash(),

            // Ro'yxat sarlavha ostidan suzib o'tadi.
            Positioned.fill(
              child: BlocSelector<ContractsBloc, ContractsState, ({bool isLoading, List<ContractInfo> contracts, DateTime? date})>(
                selector: (ContractsState state) => (isLoading: state.isLoading,contracts: state.contracts,date: state.filter.date),
                builder: (BuildContext context, ({bool isLoading, List<ContractInfo> contracts, DateTime? date}) data) => _content(
                  data: data,
                  topPadding: topInset + ScreenSize.h56,
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: BlocSelector<ContractsBloc, ContractsState, DateTime?>(
                selector: (ContractsState state) => state.filter.date,
                builder: (BuildContext context, DateTime? date) => ContractsHeader(
                  topInset: topInset,
                  date: date,
                  drawerPress: () {},
                  filterPress: () => unawaited(_openFilter(date)),
                  clearDate: () => _bloc.add(const DateCleared()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sana filtri oynasi.
  ///
  /// Bugungi kun shu yerda o'qiladi va oynaga parametr bo'lib kiradi —
  /// oynaning o'zi vaqtni bilmaydi, shuning uchun uni test qilish mumkin (9.4).
  Future<void> _openFilter(DateTime? current) => showContractsFilter(
    context: context,
    date: current,
    today: DateTime.now(),
    applyDate: (DateTime date) => _bloc.add(DateSelected(date: date)),
    clearDate: () => _bloc.add(const DateCleared()),
  );

  Widget _content({
    required ({bool isLoading, List<ContractInfo> contracts, DateTime? date}) data,
    required double topPadding,
  }) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding, bottom: ScreenSize.h30);

    if (data.isLoading) {
      return ListView(padding: padding, children: const <Widget>[ContractsSkeleton()]);
    }

    if (data.contracts.isEmpty) {
      return ListView(
        padding: padding,
        children: <Widget>[
          EmptyPlaceholder(
            icon: AppIcons.contract,
            title: "Shartnoma yo'q",
            message: data.date == null ? "Bugungi kunda tuzilgan shartnoma topilmadi" : "Tanlangan kunda shartnoma topilmadi. Boshqa sanani tanlab ko'ring",
          ),
        ],
      );
    }

    return ListView.builder(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: data.contracts.length + _headerSlot,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) return ResultsHeader(count: data.contracts.length);

        final ContractInfo contract = data.contracts[index - _headerSlot];
        return ContractCard(
          key: ValueKey<int>(contract.id),
          contract: contract,
          pressActions: () => unawaited(
            showContractActions(
              context: context,
              contract: contract,
              pressApprove: () {},
              pressEdit: () {},
              pressDetails: () {},
              pressCancel: () {},
            ),
          ),
        );
      },
    );
  }
}
