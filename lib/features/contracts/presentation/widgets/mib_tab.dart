import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/mib_debt_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/mib_summary_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/participant_select.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/report_failure_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// MIB ijro hujjatlari. Ishtirokchi almashtirilsa hisobot qayta so'raladi.
final class MibTab extends StatelessWidget {
  const MibTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ContractResultBloc bloc = context.read<ContractResultBloc>();

    return BlocBuilder<ContractResultBloc, ContractResultState>(
      builder: (BuildContext context, ContractResultState state) {
        if (state.isParticipantsLoading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
        }

        // Ishtirokchilar kelmasa tanlanadigan narsa ham yo'q.
        final Failure? participants = state.participantsFailure;
        if (participants != null) {
          return ReportFailureView(failure: participants, onRetry: () => bloc.add(const MibRetried()));
        }

        if (state.participants.isEmpty) {
          return const EmptyPlaceholder(
            icon: AppIcons.file,
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

            Expanded(child: _report(state, bloc)),
          ],
        );
      },
    );
  }

  Widget _report(ContractResultState state, ContractResultBloc bloc) {
    if (state.isMibLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    final Failure? failure = state.mibFailure;
    if (failure != null) {
      return ReportFailureView(failure: failure, onRetry: () => bloc.add(const MibRetried()));
    }

    final MibReport? report = state.mib;
    if (report == null) return const SizedBox.shrink();

    // `not_checked` — server qaytargan qonuniy holat, xato emas.
    if (!report.isChecked) {
      return EmptyPlaceholder(
        icon: AppIcons.file,
        title: "Tekshiruv o'tkazilmagan",
        message: report.resultMessage.isEmpty ? "MIB bo'yicha ma'lumot hali so'ralmagan" : report.resultMessage,
      );
    }

    return ListView(
      padding: EdgeInsets.all(ScreenSize.h12),
      children: <Widget>[
        MibSummaryCard(report: report),

        if (report.debts.isEmpty)
          const EmptyPlaceholder(
            icon: AppIcons.success,
            title: "Ijro hujjati yo'q",
            message: "Ushbu shaxsda qarzdorlik topilmadi",
          )
        else
          ...report.debts.map((MibDebt debt) => MibDebtCard(debt: debt)),
      ],
    );
  }

}
