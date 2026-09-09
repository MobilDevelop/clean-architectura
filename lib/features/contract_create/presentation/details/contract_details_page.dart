import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_sections.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_product_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_terms_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tasdiqlangan shartnomani ko'rish. Hech nima o'zgartirilmaydi.
final class ContractDetailsPage extends StatelessWidget {
  const ContractDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final ContractDetailsBloc bloc = context.read<ContractDetailsBloc>();

    return BlocSelector<ContractDetailsBloc, ContractDetailsState, Failure?>(
      selector: (ContractDetailsState state) => state.failure,
      builder: (BuildContext context, Failure? failure) => FailureView(
        failure: failure,
        onHandled: () => bloc.add(const FailureHandled()),
        onRetry: () => bloc.add(const DetailsRequested()),
        bottomInset: ScreenSize.h90,
        child: Scaffold(
          backgroundColor: AppTheme.colors.backcolor,
          body: Stack(
            children: <Widget>[
              const BackgroundWash(),

              Positioned.fill(
                child: BlocBuilder<ContractDetailsBloc, ContractDetailsState>(
                  builder: (BuildContext context, ContractDetailsState state) => _body(state, topInset),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PageHeader(title: "Shartnoma", topInset: topInset, backPress: context.pop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(ContractDetailsState state, double topInset) {
    if (state.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    final ContractDetails? details = state.details;

    // Xato `FailureView` da ko'rsatiladi.
    if (details == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset + ScreenSize.h56 + ScreenSize.h14,
        left: ScreenSize.h14,
        right: ScreenSize.h14,
        bottom: ScreenSize.h40,
      ),
      child: Column(
        children: <Widget>[
          if (details.clientName.isNotEmpty) ContractClientCard(name: details.clientName),

          ContractTermsCard(details: details),

          if (details.mibFailReason.isNotEmpty || details.katmFailReason.isNotEmpty)
            ContractFailReasons(mib: details.mibFailReason, katm: details.katmFailReason),

          ContractSection(
            title: "Tovarlar",
            icon: AppIcons.product,
            count: details.products.length,
            child: details.products.isEmpty
                ? const EmptyPlaceholder(
                    icon: AppIcons.product,
                   title: "Tovar yo'q",
                    message: "Shartnomada tovar qo'shilmagan",
                  )
                : Column(
                    children: details.products
                        .map((ContractProduct e) => ContractProductCard(product: e))
                        .toList(),
                  ),
          ),

          ContractSection(
            title: "Kafillar",
            icon: AppIcons.person,
            count: details.guarantors.length,
            child: details.guarantors.isEmpty
                ? Text("Kafil qo'shilmagan", style: AppTheme.data.textTheme.bodyMedium)
                : Column(children: details.guarantors.map(ContractGuarantorRow.new).toList()),
          ),

          if (!details.card.isEmpty) ContractCardSection(card: details.card),
          if (details.benefit != null) ContractBenefitSection(benefit: details.benefit!),

          if (details.hasFile) ...<Widget>[
            Gap(ScreenSize.h6),
            MainButton(
              text: "Shartnoma faylini ochish",
              leftIcon: AppIcons.file,
              onPressed: () => unawaited(_openFile(details.fileUrl)),
            ),
          ],
        ],
      ),
    );
  }

  /// Fayl tashqi ilovada ochiladi — yuklab olish keyingi bosqichda.
  Future<void> _openFile(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null) return;

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
