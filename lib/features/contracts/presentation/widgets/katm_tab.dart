import 'package:colloborator_v3/features/contracts/domain/entities/katm_row.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/katm_labels.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_chart.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_fields.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_gauge.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/katm_table_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/participant_select.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/report_failure_view.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// KATM kredit byurosi hisoboti.
final class KatmTab extends StatelessWidget {
  const KatmTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ContractResultBloc bloc = context.read<ContractResultBloc>();

    return BlocBuilder<ContractResultBloc, ContractResultState>(
      builder: (BuildContext context, ContractResultState state) {
        if (state.isParticipantsLoading || state.isKatmLoading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
        }

        final Failure? participants = state.participantsFailure;
        if (participants != null) {
          return ReportFailureView(failure: participants, onRetry: () => bloc.add(const KatmRetried()));
        }

        final Failure? failure = state.katmFailure;
        if (failure != null) {
          return ReportFailureView(failure: failure, onRetry: () => bloc.add(const KatmRetried()));
        }

        if (state.participants.isEmpty) {
          return const EmptyPlaceholder(
            icon: AppIcons.graphic,
            title: "Ishtirokchi topilmadi",
            message: "Ushbu shartnoma bo'yicha hisobot mavjud emas",
          );
        }

        return Column(
          children: <Widget>[
            Gap(ScreenSize.h12),
            ParticipantSelect(
              participants: state.participants,
              selectedId: state.selectedClientId,
              onSelected: (int id) => bloc.add(ParticipantSelected(id)),
            ),

            Expanded(child: _report(state.katm)),
          ],
        );
      },
    );
  }

  Widget _report(KatmReport? report) {
    if (report == null) return const SizedBox.shrink();

    if (!report.isAvailable) {
      return const EmptyPlaceholder(
        icon: AppIcons.graphic,
        title: "Hisobot mavjud emas",
        message: "KATM bo'yicha ma'lumot hali so'ralmagan",
      );
    }

    return ListView(
      padding: EdgeInsets.all(ScreenSize.h12),
      children: <Widget>[
        if (report.hasWarning) _warning(report),

        ResultCard(
          title: report.title.isEmpty ? "Hisobot" : report.title,
          icon: AppIcons.file,
          color: AppTheme.colors.grey,
          child: KatmFields(row: _metaRow(report.meta), labels: KatmLabels.meta),
        ),

        ResultCard(
          title: "Skoring balli",
          icon: AppIcons.star,
          color: AppTheme.colors.primary,
          child: KatmGauge(scoring: report.scoring),
        ),

        if (report.dynamics.isNotEmpty)
          ResultCard(
            title: "Ball dinamikasi",
            icon: AppIcons.graphic,
            color: AppTheme.colors.blue,
            child: KatmChart(points: report.dynamics),
          ),

        ResultCard(
          title: "Kredit axboroti subyekti",
          icon: AppIcons.person,
          color: AppTheme.colors.green,
          child: KatmFields(row: report.subject, labels: KatmLabels.subject),
        ),

        ResultCard(
          title: "Umumiy ko'rsatkichlar",
          icon: AppIcons.info,
          color: AppTheme.colors.blue,
          child: KatmFields(row: report.overview, labels: KatmLabels.overview),
        ),

        // Bo'limlar tartibi backenddan keladi — ilova ro'yxatni o'zida saqlamaydi.
        ...report.layout.map((KatmSection section) {
          final KatmTable? table = report.tableOf(section.key);
          if (table == null || (table.rows.isEmpty && table.totals == null)) return const SizedBox.shrink();

          return KatmTableCard(section: section, table: table);
        }),

        if (report.comments.isNotEmpty)
          ResultCard(
            title: "Huquqiy izohlar",
            icon: AppIcons.file,
            color: AppTheme.colors.grey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: report.comments
                  .map(
                    (KatmComment comment) => Padding(
                      padding: EdgeInsets.only(bottom: ScreenSize.h6),
                      child: Text(
                        "${comment.order}. ${comment.content}",
                        style: AppTheme.data.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        if (report.scoredAt.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: ScreenSize.h4),
            child: Text(
              "Tekshirilgan: ${report.scoredAt}",
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  /// Rekvizitlar `KatmFields` bilan bir xil ko'rinishda chizilishi uchun
  /// qatorga aylantiriladi.
  KatmRow _metaRow(KatmMeta meta) => KatmRow(<KatmField>[
    KatmField(key: 'report_name', value: meta.reportName, isMoney: false),
    KatmField(key: 'claim_id', value: meta.claimId, isMoney: false),
    KatmField(key: 'claim_date', value: meta.claimDate, isMoney: false),
    KatmField(key: 'org_name', value: meta.orgName, isMoney: false),
    KatmField(key: 'subject_type', value: meta.subjectType, isMoney: false),
  ]);

  Widget _warning(KatmReport report) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: ScreenSize.h12),
    padding: EdgeInsets.all(ScreenSize.h12),
    decoration: BoxDecoration(
      color: AppTheme.colors.red.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(ScreenSize.r16),
      border: Border.all(color: AppTheme.colors.red.withValues(alpha: .3)),
    ),
    child: Row(
      children: <Widget>[
        Icon(Icons.warning_amber_rounded, color: AppTheme.colors.red, size: ScreenSize.h22),

        Gap(ScreenSize.w10),
        Expanded(
          child: Text(
            report.hasCreditBan ? "Kreditlash taqiqlangan" : "Qora ro'yxatda",
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.red),
          ),
        ),
      ],
    ),
  );

}
