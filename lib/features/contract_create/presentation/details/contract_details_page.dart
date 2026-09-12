import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_details_sections.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_file_bar.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_product_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/details/contract_terms_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tasdiqlangan shartnomani ko'rish. Hech nima o'zgartirilmaydi.
final class ContractDetailsPage extends StatelessWidget {
  const ContractDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    final ContractDetailsBloc bloc = context.read<ContractDetailsBloc>();

    return BlocListener<ContractDetailsBloc, ContractDetailsState>(
      listenWhen: (ContractDetailsState previous, ContractDetailsState current) =>
          current.shareFile != null && previous.shareFile == null,
      listener: (BuildContext context, ContractDetailsState state) {
        final File? file = state.shareFile;
        if (file != null) unawaited(_share(context, file));
      },
      child: BlocSelector<ContractDetailsBloc, ContractDetailsState, Failure?>(
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
                  builder: (BuildContext context, ContractDetailsState state) => _body(context, state, topInset),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PageHeader(title: "Shartnoma", topInset: topInset, backPress: context.pop),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BlocBuilder<ContractDetailsBloc, ContractDetailsState>(
                  buildWhen: (ContractDetailsState previous, ContractDetailsState current) =>
                      previous.isFileLoading != current.isFileLoading ||
                      previous.details?.fileUrl != current.details?.fileUrl,
                  builder: (BuildContext context, ContractDetailsState state) {
                    final ContractDetails? details = state.details;

                    // Ma'lumot kelmaguncha panel chizilmaydi: fayl bor-yo'qligi
                    // hali noma'lum.
                    if (details == null) return const SizedBox.shrink();

                    return ContractFileBar(
                      hasFile: details.hasFile,
                      isSharing: state.isFileLoading,
                      openPress: () => unawaited(_openFile(context, details.fileUrl)),
                      sharePress: () =>
                          context.read<ContractDetailsBloc>().add(const FileShareRequested()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _body(BuildContext context, ContractDetailsState state, double topInset) {
    if (state.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    final ContractDetails? details = state.details;

    // Xato `FailureView` da ko'rsatiladi.
    if (details == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topInset + ScreenSize.h56 + ScreenSize.h14,
        left: ScreenSize.h14,
        right: ScreenSize.h14,
        // Pastdagi fayl paneli kontentni yopib qo'ymasin.
        bottom: ScreenSize.h90,
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

        ],
      ),
    );
  }

  /// Fayl tashqi ilovada ochiladi.
  ///
  /// Natija tekshiriladi: ochadigan ilova bo'lmasa `launchUrl` `false`
  /// qaytaradi va bosish jimgina yo'qolardi (5.8).
  Future<void> _openFile(BuildContext context, String url) async {
    final Uri? uri = Uri.tryParse(url);

    final bool isOpened = uri == null
        ? false
        : await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (isOpened) return;

    await CustomAnimatedToast.showInfo("Faylni ochadigan ilova topilmadi");
  }

  /// Ulashish oynasi — UI ta'siri, shuning uchun bloc emas, sahifa ochadi (6.2).
  Future<void> _share(BuildContext context, File file) async {
    final ContractDetailsBloc bloc = context.read<ContractDetailsBloc>();

    // Fayl holatdan darhol olib tashlanadi: ekran qayta qurilganda oyna
    // ikkinchi marta ochilmasin.
    bloc.add(const FileShared());

    await SharePlus.instance.share(ShareParams(files: <XFile>[XFile(file.path)]));
  }
}
