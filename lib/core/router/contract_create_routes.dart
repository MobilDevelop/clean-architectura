import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/router/coordinator.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/widgets/states/route_error_view.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/payment_schedule.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bonus/manager_bonus_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bonus/manager_bonus_page.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_page.dart';
import 'package:colloborator_v3/features/contract_create/presentation/katm_skip/katm_skip_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/katm_skip/katm_skip_page.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/contract_products_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/payment_schedule_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/schedule/payment_schedule_page.dart';
import 'package:colloborator_v3/features/contract_create/presentation/tariff/special_tariff_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/tariff/special_tariff_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/contract_tap_text.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/face_id_page.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/guarantor_picker_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Shartnoma tuzish ekrani va uning qo'shimcha ekranlari.
///
/// Nega alohida fayl: `coordinator.dart` ilovaning butun daraxtini saqlaydi
/// va bir featurening o'sishi bilan o'sib ketmasligi kerak.
List<RouteBase> contractCreateRoutes() => <RouteBase>[
  GoRoute(
    name: Routes.addContract.name,
    path: Routes.addContract.path,
    pageBuilder: (context, state) {
      final extra = state.extra;

      // Chaqiruvchi ekranlar `contract_create` ni import qilmasligi uchun
      // argument oddiy yozuv (1.3). Entityga aylantirish — routerning ishi.
      if (extra is! ({int clientId, int? contractId, bool canSkipKatm})) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: () => context.go(Routes.customer.path)),
        );
      }

      final args = ContractCreateArgs(
        clientId: extra.clientId,
        contractId: extra.contractId,
        canSkipKatm: extra.canSkipKatm,
      );

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => getIt<ContractCreateBloc>(param1: args)..add(const ContractRequested())),
            // Qoralamani shu bloc yaratadi, shuning uchun u `contractId` siz
            // ham mavjud bo'lishi kerak.
            BlocProvider(create: (context) => getIt<ContractProductsBloc>(param1: args)..add(const ProductsRequested())),
          ],
          child: ContractCreatePage(
            productPicker: (BuildContext context) => context.push<ProductDraft>(Routes.productPicker.path),
            guarantorPicker: (BuildContext context) =>
                context.push<GuarantorPick>(Routes.guarantorPicker.path),
            extraOpener: _openExtra,
          ),
        ),
      );
    },
  ),

  GoRoute(
    name: Routes.guarantorPicker.name,
    path: Routes.guarantorPicker.path,
    pageBuilder: (context, state) => buildScaleTransitionPage<GuarantorPick>(
      context: context,
      state: state,
      child: BlocProvider(
        create: (context) => getIt<CustomersBloc>(),
        child: GuarantorPickerPage(
          faceCheckOpener: (BuildContext context, FaceIdPrefill? prefill) =>
              context.push<CustomerInfo>(Routes.faceId.path, extra: prefill),
          formOpener: (BuildContext context, CustomerInfo customer) =>
              context.push<bool>(Routes.addCustomer.path, extra: (info: customer, isEdit: false)),
        ),
      ),
    ),
  ),

  GoRoute(
    name: Routes.paymentSchedule.name,
    path: Routes.paymentSchedule.path,
    pageBuilder: (context, state) {
      final extra = state.extra;

      if (extra is! ScheduleQuery) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: () => context.pop()),
        );
      }

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => getIt<PaymentScheduleBloc>(param1: extra)..add(const ScheduleRequested()),
          child: const PaymentSchedulePage(),
        ),
      );
    },
  ),

  GoRoute(
    name: Routes.specialTariff.name,
    path: Routes.specialTariff.path,
    pageBuilder: (context, state) {
      final extra = state.extra;

      if (extra is! ({int contractId, int termMonths, AppliedTariff applied})) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: () => context.pop()),
        );
      }

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => getIt<SpecialTariffBloc>(
            param1: (contractId: extra.contractId, termMonths: extra.termMonths),
            param2: extra.applied,
          )..add(const TariffsRequested()),
          child: const SpecialTariffPage(),
        ),
      );
    },
  ),

  GoRoute(
    name: Routes.managerBonus.name,
    path: Routes.managerBonus.path,
    pageBuilder: (context, state) {
      final extra = state.extra;

      if (extra is! ContractBenefit) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: () => context.pop()),
        );
      }

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => getIt<ManagerBonusBloc>(param1: extra),
          child: const ManagerBonusPage(),
        ),
      );
    },
  ),

  GoRoute(
    name: Routes.katmSkip.name,
    path: Routes.katmSkip.path,
    pageBuilder: (context, state) {
      final extra = state.extra;

      if (extra is! ({int contractId, String mib, String katm})) {
        return buildScaleTransitionPage<bool>(
          context: context,
          state: state,
          child: RouteErrorView(location: state.uri.toString(), onBack: () => context.pop()),
        );
      }

      return buildScaleTransitionPage<bool>(
        context: context,
        state: state,
        child: BlocProvider(
          create: (context) => getIt<KatmSkipBloc>(
            param1: extra.contractId,
            param2: (mib: extra.mib, katm: extra.katm),
          )..add(const ReasonsRequested()),
          child: const KatmSkipPage(),
        ),
      );
    },
  ),
];

/// Qo'shimcha ekranni ochadi va "serverda o'zgarish bo'ldimi" ni qaytaradi.
///
/// Marshrut bilimining yagona joyi: sahifa marshrutni bilmaydi va yangi
/// ekran qo'shilganda `switch` qamrab olinmagani kompilyatsiyada xato
/// beradi (O — Open/Closed).
Future<bool?> _openExtra(
  BuildContext context,
  ContractExtra extra,
  ContractCreateState state,
) async {
  final int contractId = state.contractId ?? 0;
  final ContractDetails? details = state.details;

  switch (extra) {
    case ContractExtra.schedule:
      return context.push<bool>(
        Routes.paymentSchedule.path,
        extra: ScheduleQuery(
          contractId: contractId,
          termMonths: state.form.termMonths,
          paymentDay: state.form.paymentDay,
          isInformal: state.form.basis == IncomeBasis.informal,
        ),
      );

    case ContractExtra.tariff:
      return context.push<bool>(
        Routes.specialTariff.path,
        extra: (
          contractId: contractId,
          termMonths: state.form.termMonths,
          applied: details?.tariff ?? const AppliedTariff(id: 0, name: '', isActive: false),
        ),
      );

    case ContractExtra.bonus:
      final ContractBenefit? benefit = details?.benefit;
      if (benefit == null) return null;

      return context.push<bool>(Routes.managerBonus.path, extra: benefit);

    case ContractExtra.katmSkip:
      return context.push<bool>(
        Routes.katmSkip.path,
        extra: (
          contractId: contractId,
          mib: details?.mibFailReason ?? '',
          katm: details?.katmFailReason ?? '',
        ),
      );

    case ContractExtra.underwriter:
      // Anderrayter alohida feature sifatida yozilmoqda. Tugma jimgina
      // turmasligi uchun holat ochiq aytiladi (5.8).
      await CustomAnimatedToast.showInfo(ContractTapText.underwriter);

      return null;
  }
}
