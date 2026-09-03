import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/scoring_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/scoring_check_row.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/scoring_contract_card.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/scoring_header.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/scoring_totals_card.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/section_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Skoring natijasini ochadi. Oynaning o'z bloci bor: natija boshqa hech
/// qayerda kerak emas.
Future<void> showScoringSheet({required BuildContext context, required int customerId}) => showAppSheet(
  context: context,
  child: BlocProvider<ScoringBloc>(
    create: (BuildContext context) => getIt<ScoringBloc>()..add(ScoringRequested(customerId)),
    child: ScoringSheet(customerId: customerId),
  ),
);

final class ScoringSheet extends StatelessWidget {
  const ScoringSheet({super.key, required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) {
    final ScoringBloc bloc = context.read<ScoringBloc>();

    // Xato guruhiga qarab yo'naltiriladi (5.6): 401 da chiqarish, aloqa
    // uzilganda banner va "Qayta urinish".
    return BlocSelector<ScoringBloc, ScoringState, Failure?>(
      selector: (ScoringState state) => state.failure,
      builder: (BuildContext context, Failure? failure) => FailureView(
        failure: failure,
        onHandled: () => bloc.add(const ScoringFailureHandled()),
        onRetry: () => bloc.add(ScoringRequested(customerId)),
        child: _sheet(context),
      ),
    );
  }

  Widget _sheet(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .85,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Text(
              "Skoring natijasi",
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            Expanded(child: BlocBuilder<ScoringBloc, ScoringState>(builder: _body)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ScoringState state) {
    if (state.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    final ScoringInfo? info = state.info;

    // Xato `FailureView` da ko'rsatiladi; bu yerda faqat bo'sh joy qoladi.
    if (info == null) return const SizedBox.shrink();

    return ListView(
      padding: EdgeInsets.only(bottom: ScreenSize.h16),
      children: <Widget>[
        ScoringHeader(info: info),

        if (info.reason.isNotEmpty) ...<Widget>[Gap(ScreenSize.h10), _note("Izoh", info.reason)],
        if (info.carLimit.isNotEmpty) ...<Widget>[Gap(ScreenSize.h10), _note("Avto limit", info.carLimit)],

        Gap(ScreenSize.h20),
        const SectionTitle("Tekshiruvlar"),
        Container(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h4),
          decoration: BoxDecoration(
            color: AppTheme.colors.white,
            borderRadius: BorderRadius.circular(ScreenSize.r16),
            border: AppSurface.border(),
          ),
          child: Column(
            children: <Widget>[
              ScoringCheckRow(label: "Qora ro'yxat", isPassed: info.passBlackList),
              ScoringCheckRow(label: "To'lov jadvali", isPassed: info.passPaymentGraphics),
              ScoringCheckRow(label: "To'lov intizomi", isPassed: info.passPaymentDiscipline),
              ScoringCheckRow(label: "Sudlanganlik", isPassed: info.passCriminalRecord),
            ],
          ),
        ),

        Gap(ScreenSize.h20),
        const SectionTitle("Shartnomalar"),
        ScoringTotalsCard(title: "Aktiv", totals: info.active, color: AppTheme.colors.yellow),

        Gap(ScreenSize.h8),
        ScoringTotalsCard(title: "Kafil", totals: info.guarantor, color: AppTheme.colors.blue),

        Gap(ScreenSize.h8),
        ScoringTotalsCard(title: "Yopilgan", totals: info.closed, color: AppTheme.colors.primary),

        ..._group("Aktiv shartnomalar", info.activeContracts),
        ..._group("Kafillikdagi shartnomalar", info.guarantorContracts),
        ..._group("Yopilgan shartnomalar", info.closedContracts),
      ],
    );
  }

  List<Widget> _group(String title, List<ScoringContract> contracts) => contracts.isEmpty
      ? const <Widget>[]
      : <Widget>[
          Gap(ScreenSize.h20),
          SectionTitle(title),
          ...contracts.map((ScoringContract contract) => ScoringContractCard(contract: contract)),
        ];

  Widget _note(String title, String text) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.yellow.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(ScreenSize.r16),
      border: Border.all(color: AppTheme.colors.yellow.withValues(alpha: .3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h4),
        Text(text, style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
      ],
    ),
  );
}
