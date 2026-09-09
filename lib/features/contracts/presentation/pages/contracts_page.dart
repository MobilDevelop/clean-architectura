import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/states/results_header.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/pull_refresh.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts_state.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_action_sheet.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contracts_header.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contracts_skeleton.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_actions.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/contract_tap_text.dart';
import 'package:colloborator_v3/core/widgets/sheets/date_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Ro'yxatning birinchi o'rni sarlavhaga ketadi.
const int _headerSlot = 1;

/// Taqvimda nechta yil orqaga qarash mumkin.
const int _yearSpan = 1;

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

    // Bildirishnoma bosilgan shartnomani ochadi.
    //
    // Nega ro'yxat yuklanib bo'lgandan keyin: push kelgan shartnoma eski
    // ro'yxatda bo'lmasligi mumkin (sana filtri yoki hali o'qilmagan) — o'shanda
    // "topilmadi" deyish noto'g'ri bo'lardi. Xato bo'lsa belgi saqlanadi:
    // «Qayta urinish» muvaffaqiyatli tugagach shartnoma baribir ochiladi.
    return BlocListener<ContractsBloc, ContractsState>(
      listenWhen: (ContractsState previous, ContractsState current) =>
          current.openContractId != 0 && previous.isLoading && !current.isLoading && current.failure == null,
      listener: (BuildContext context, ContractsState state) => unawaited(_openFromPush(state)),
      child: Scaffold(
        backgroundColor: AppTheme.colors.backcolor,
        body: BlocSelector<ContractsBloc, ContractsState, Failure?>(
          selector: (ContractsState state) => state.failure,
          builder: (BuildContext context, Failure? failure) => FailureView(
            failure: failure,
            onHandled: () => _bloc.add(const FailureHandled()),
            onRetry: () => _bloc.add(const ContractsGet()),
            child: Stack(
              children: <Widget>[
                const BackgroundWash(),

                // Ro'yxat sarlavha ostidan suzib o'tadi.
                Positioned.fill(
                  child:
                      BlocSelector<
                        ContractsBloc,
                        ContractsState,
                        ({bool isLoading, List<ContractInfo> contracts, DateTime? date})
                      >(
                        selector: (ContractsState state) =>
                            (isLoading: state.isLoading, contracts: state.contracts, date: state.filter.date),
                        builder:
                            (
                              BuildContext context,
                              ({bool isLoading, List<ContractInfo> contracts, DateTime? date}) data,
                            ) => PullRefresh<ContractsBloc, ContractsState>(
                              isLoading: (ContractsState state) => state.isLoading,
                              refreshPress: () => _bloc.add(const ContractsGet()),
                              edgeOffset: topInset + ScreenSize.h56,
                              child: _content(data: data, topPadding: topInset + ScreenSize.h56),
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
        ),
      ),
    );
  }

  /// Bildirishnoma bosilgan shartnomani ro'yxatdan topib, kartani bosgandek
  /// ochadi — statusiga qarab amal oynasi, tovarlar yoki holat matni.
  ///
  /// Nega alohida marshrut emas: bosish natijasi kartani bosish bilan bir xil
  /// bo'lishi kerak. Ikkinchi yo'l yozilsa, status qoidasi ikki joyda turardi.
  Future<void> _openFromPush(ContractsState state) async {
    // Belgi bir marta ishlaydi: ro'yxat keyin yana yangilansa oyna ikkinchi
    // marta ochilmaydi.
    _bloc.add(const ContractOpened());

    final ContractInfo? contract = _find(state.contracts, state.openContractId);

    if (contract == null) {
      await CustomAnimatedToast.showInfo(ContractTapText.pushNotFound);
      return;
    }

    await _onTap(contract);
  }

  ContractInfo? _find(List<ContractInfo> contracts, int id) {
    for (final ContractInfo contract in contracts) {
      if (contract.id == id) return contract;
    }

    return null;
  }

  /// Sana filtri oynasi.
  ///
  /// Bugungi kun shu yerda o'qiladi va oynaga parametr bo'lib kiradi —
  /// oynaning o'zi vaqtni bilmaydi, shuning uchun uni test qilish mumkin (9.4).
  Future<void> _openFilter(DateTime? current) {
    final DateTime today = DateTime.now();

    return showDateSheet(
      context: context,
      title: "Sana bo'yicha filtr",
      subtitle: "Kunni tanlang",
      date: current,
      firstDate: DateTime(today.year - _yearSpan, today.month, today.day),
      lastDate: today,
      onPicked: (DateTime date) => _bloc.add(DateSelected(date: date)),
      onClear: () => _bloc.add(const DateCleared()),
    );
  }

  Future<void> _openResult(ContractInfo contract) =>
      context.push(Routes.contractResult.path, extra: contract);

  /// Shartnoma bosilganda avval statusga qaraladi: ayrim holatlarda amallar
  /// oynasi emas, aniq bir oqim ochilishi kerak.
  Future<void> _onTap(ContractInfo contract) async {
    switch (ContractActions.tapOf(contract.statusCode)) {
      case ContractTap.selectIncome:
        await CustomAnimatedToast.showInfo(ContractTapText.selectIncome);
      case ContractTap.confirmSms:
        await CustomAnimatedToast.showInfo(ContractTapText.confirmSms);
      case ContractTap.viewProduct:
        await context.push(Routes.contractDetails.path, extra: contract.id);
      case ContractTap.showActions:
        await _openActions(contract);
    }
  }

  /// Shartnomani tahrirlash. Argument oddiy yozuv — sahifa `contract_create`
  /// ni import qilmaydi (1.3).
  Future<void> _openEdit(ContractInfo contract) async {
    final bool? isSubmitted = await context.push<bool>(
      Routes.addContract.path,
      // KATM skipni ko'rsatish huquqi ro'yxatdan keladi: `loans/{id}`
      // bu bayroqni qaytarmaydi.
      extra: (clientId: contract.clientId, contractId: contract.id, canSkipKatm: contract.showButtonKATM),
    );

    if (isSubmitted ?? false) {
      // Yuborilgan bo'lsa ro'yxatni `ContractChanges` allaqachon yangilagan —
      // ikkinchi so'rov ortiqcha.
      await CustomAnimatedToast.showSuccess("Shartnoma yuborildi");
      return;
    }

    // Yuborilmasa ham tovar, kafil yoki karta serverga yozilgan bo'lishi
    // mumkin: ular alohida bloclarda va bu signalni bermaydi.
    _bloc.add(const ContractsGet());
  }

  Future<void> _openActions(ContractInfo contract) => showContractActions(
    context: context,
    contract: contract,
    pressDetails: () => unawaited(_openResult(contract)),
    pressEdit: () => unawaited(_openEdit(contract)),
    // Amal bajarilgach ro'yxatdagi holat eskiradi.
    onChanged: () => _bloc.add(const ContractsGet()),
    onSigningRequested: () => unawaited(CustomAnimatedToast.showInfo(ContractTapText.signing)),
  );

  Widget _content({
    required ({bool isLoading, List<ContractInfo> contracts, DateTime? date}) data,
    required double topPadding,
  }) {
    final EdgeInsets padding = EdgeInsets.only(top: topPadding, bottom: ScreenSize.h30);

    // Skelet faqat birinchi yuklashda. Yangilashda ro'yxat ekranda qoladi,
    // aks holda tortib yangilash paytida u yo'qolib ketadi.
    if (data.isLoading && data.contracts.isEmpty) {
      return ListView(padding: padding, children: const <Widget>[ContractsSkeleton()]);
    }

    if (data.contracts.isEmpty) {
      return ListView(
        padding: padding,
        // Bo'sh ro'yxatni ham tortib yangilash mumkin.
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          EmptyPlaceholder(
            icon: AppIcons.contract,
            title: "Shartnoma yo'q",
            message: data.date == null
                ? "Bugungi kunda tuzilgan shartnoma topilmadi"
                : "Tanlangan kunda shartnoma topilmadi. Boshqa sanani tanlab ko'ring",
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
          pressActions: () => unawaited(_onTap(contract)),
        );
      },
    );
  }
}
