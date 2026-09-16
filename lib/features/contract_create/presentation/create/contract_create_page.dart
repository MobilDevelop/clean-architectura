import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/contract/contract_status_style.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/contract_create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_summary_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_tab_bar.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_tabs.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/guarantors_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Kam ishlatiladigan ekranni ochadi. Marshrutni sahifa emas, router biladi.
typedef ExtraOpener =
    Future<bool?> Function(BuildContext context, ContractExtra extra, ContractCreateState state);

/// Kafilning anderrayteri va instrumentlari uchun — shartnoma holati ham
/// kerak, chunki anderrayter ekrani `isFormal` va `hasCard` ga qarab
/// bo'limlarini tanlaydi.
typedef GuarantorExtraRouter =
    Future<void> Function(
      BuildContext context,
      GuarantorExtra extra,
      ContractGuarantor guarantor,
      ContractCreateState state,
    );

/// Shartnoma tuzish — uch tab: shartnoma, tovarlar, kafillar.
///
/// Nega tab: eng ko'p ishlatiladigan uchta narsa bitta ekranda turadi va
/// ular orasida o'tish uchun orqaga qaytish shart emas. Kam ishlatiladigan
/// va shartli qismlar (jadval, tarif, bonus, KATM, anderrayter) tabga
/// tiqilmaydi — ular «Qo'shimcha» qatorlaridan ochiladi, aks holda birinchi
/// tab flex'dagidek cheksiz o'sadi.
final class ContractCreatePage extends StatelessWidget {
  const ContractCreatePage({
    super.key,
    required this.productPicker,
    required this.guarantorPicker,
    required this.extraOpener,
    required this.guarantorExtraOpener,
  });

  final Future<ProductDraft?> Function(BuildContext context) productPicker;
  final Future<GuarantorPickResult?> Function(BuildContext context) guarantorPicker;
  final ExtraOpener extraOpener;
  final GuarantorExtraRouter guarantorExtraOpener;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractCreateBloc, ContractCreateState>(
      listenWhen: (ContractCreateState previous, ContractCreateState current) =>
          current.isSubmitted && !previous.isSubmitted,
      listener: (BuildContext context, ContractCreateState state) => context.pop(true),
      builder: (BuildContext context, ContractCreateState state) {
        final ContractCreateBloc bloc = context.read<ContractCreateBloc>();

        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const Retried()),
          bottomInset: ScreenSize.h80,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: AppTheme.colors.backcolor,
              // Klaviatura ochilganda pastdagi tugma tabni siqib qo'ymasin.
              resizeToAvoidBottomInset: false,
              body: Stack(
                children: <Widget>[
                  const BackgroundWash(),
                  Positioned.fill(child: _content(context, state, bloc)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, ContractCreateState state, ContractCreateBloc bloc) => Column(
    children: <Widget>[
      PageHeader(
        title: state.args.isEdit ? "Shartnomani tahrirlash" : "Shartnoma tuzish",
        topInset: MediaQuery.paddingOf(context).top,
        backPress: () => context.pop(false),
      ),

      if (state.isLoading && state.details == null)
        Expanded(
          child: Center(child: CircularProgressIndicator(color: AppTheme.colors.primary)),
        )
      else ...<Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h12, ScreenSize.h16, ScreenSize.h12),
          child: ContractSummaryCard(
            clientName: state.details?.clientName ?? '',
            contractNumber: state.contractId == null ? '' : "${state.contractId}",
            statusLabel: state.details?.statusCode == null ? '' : ContractStatusStyle.label(ContractStatus.fromCode(state.details?.statusCode ?? 0)),
            statusColor: ContractStatusStyle.color(ContractStatus.fromCode(state.details?.statusCode ?? 0)),
          ),
        ),

        ContractTabBar(
          productCount: state.productCount,
          guarantorCount: state.details?.guarantors.length ?? 0,
        ),

        Expanded(
          child: ContractTabs(
            state: state,
            productPicker: productPicker,
            guarantorPicker: guarantorPicker,
            extraPressed: (ContractExtra extra) => _openExtra(context, extra, state),
            guarantorExtraOpener: (BuildContext context, GuarantorExtra extra, ContractGuarantor guarantor) =>
                _openGuarantorExtra(context, extra, guarantor, state),
          ),
        ),
      ],

      SafeArea(
        top: false,
        child: MainButton(
          text: "Yuborish",
          margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
          showLoading: state.isSubmitting,
          // Tugma hech qachon o'chirilmaydi: to'ldirilmagan bo'lsa nima
          // yetishmayotgani ko'rsatiladi (5.8).
          onPressed: () => bloc.add(const SubmitRequested()),
        ),
      ),
    ],
  );

  Future<void> _openExtra(BuildContext context, ContractExtra extra, ContractCreateState state) async {
    final ContractCreateBloc bloc = context.read<ContractCreateBloc>();
    await extraOpener(context, extra, state);

    // Shartnoma har qaytishda qayta o'qiladi. Ekranning `pop` natijasiga
    // tayanib bo'lmaydi: tizim orqaga tugmasi (Android) yoki chetdan surish
    // (iOS) bilan chiqilganda u `null` bo'lib keladi va o'zgarish ekranda
    // ko'rinmay qolardi. Ortiqcha bitta `GET` — jimgina eskirgan ma'lumotdan
    // arzon (5.8).
    bloc.add(const ContractRequested());
  }

  /// Kafilning hujjatlari yoki instrumentlari o'zgarsa, kafillar ro'yxati
  /// shartnoma javobidan keladi — shuning uchun u ham qayta o'qiladi.
  Future<void> _openGuarantorExtra(
    BuildContext context,
    GuarantorExtra extra,
    ContractGuarantor guarantor,
    ContractCreateState state,
  ) async {
    final ContractCreateBloc bloc = context.read<ContractCreateBloc>();

    await guarantorExtraOpener(context, extra, guarantor, state);

    bloc.add(const ContractRequested());
  }
}
