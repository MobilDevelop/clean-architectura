import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_extras.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/product_draft.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_terms_tab.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/contract_guarantors_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/guarantors/guarantors_tab.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/contract_card_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/contract_products_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/products/products_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Uch tabning tanasi va resurs bloclari.
///
/// Karta va kafil bloclari `contractId` paydo bo'lgandan keyingina
/// yaratiladi: ikkalasi ham shartnomaga biriktiriladi va qoralamasiz
/// yozilmaydi. Qoralamani esa tovar tabi yaratadi.
final class ContractTabs extends StatelessWidget {
  const ContractTabs({
    super.key,
    required this.state,
    required this.productPicker,
    required this.guarantorPicker,
    required this.extraPressed,
  });

  final ContractCreateState state;
  final Future<ProductDraft?> Function(BuildContext context) productPicker;
  final Future<GuarantorPickResult?> Function(BuildContext context) guarantorPicker;
  final void Function(ContractExtra extra) extraPressed;

  @override
  Widget build(BuildContext context) {
    final int? contractId = state.contractId;

    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        // Qoralama yaratildi. Alohida signal: tovar qo'shish undan keyin
        // yiqilsa ham qolgan bo'limlar ochilishi kerak.
        BlocListener<ContractProductsBloc, ContractProductsState>(
          listenWhen: (ContractProductsState previous, ContractProductsState current) => current.contractId != previous.contractId && current.contractId != null,
          listener: (BuildContext context, ContractProductsState products) => context.read<ContractCreateBloc>().add(ContractIdReceived(products.contractId ?? 0)),
        ),

        // Tovar yozilgach shartnoma qayta o'qiladi: summa, tarif va status
        // shu javobdan keladi.
        BlocListener<ContractProductsBloc, ContractProductsState>(
          listenWhen: (ContractProductsState previous, ContractProductsState current) => current.revision != previous.revision,
          listener: (BuildContext context, ContractProductsState products) => context.read<ContractCreateBloc>().add(const ContractRequested()),
        ),

        // To'ldirilmagan joy boshqa tabda bo'lsa, o'sha tabga o'tiladi —
        // aks holda "Yuborish" bosiladi va hech nima ko'rinmaydi (5.8).
        BlocListener<ContractCreateBloc, ContractCreateState>(
          listenWhen: (ContractCreateState previous, ContractCreateState current) => current.issue != previous.issue && current.issue == ContractFormIssue.noProducts,
          listener: (BuildContext context, ContractCreateState state) => DefaultTabController.of(context).animateTo(1),
        ),
      ],
      child: contractId == null ? _tabs(context) : _withResources(context, contractId),
    );
  }

  Widget _withResources(BuildContext context, int contractId) => MultiBlocProvider(
    // Qoralama paydo bo'lganda bloclar bir marta qayta yaratiladi.
    key: ValueKey<int>(contractId),
    providers: <BlocProvider<dynamic>>[
      BlocProvider<ContractCardBloc>(
        create: (BuildContext context) => getIt<ContractCardBloc>(
          param1: (contractId: contractId, clientId: state.args.clientId),
          param2: state.details?.card ?? const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
        ),
      ),
      BlocProvider<ContractGuarantorsBloc>(
        create: (BuildContext context) => getIt<ContractGuarantorsBloc>(
          param1: (contractId: contractId, clientId: state.args.clientId),
          param2: state.details?.guarantors ?? const <ContractGuarantor>[],
        ),
      ),
    ],
    child: BlocListener<ContractGuarantorsBloc, ContractGuarantorsState>(
      listenWhen: (ContractGuarantorsState previous, ContractGuarantorsState current) => current.revision != previous.revision,
      listener: (BuildContext context, ContractGuarantorsState guarantors) => context.read<ContractCreateBloc>().add(const ContractRequested()),
      child: _tabs(context),
    ),
  );

  Widget _tabs(BuildContext context) => TabBarView(
    children: <Widget>[
      ContractTermsTab(state: state, extraPressed: extraPressed),
      ProductsTab(productPicker: productPicker),
      state.hasContract ? GuarantorsTab(guarantorPicker: guarantorPicker) : const GuarantorsPlaceholder(),
    ],
  );
}
