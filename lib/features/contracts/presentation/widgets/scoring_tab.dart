import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_result_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/flex_messages_card.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/report_failure_view.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/scoring_participant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ELMA skoring qarori. Har bir ishtirokchi uchun alohida bo'lim.
final class ScoringTab extends StatelessWidget {
  const ScoringTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ContractResultBloc bloc = context.read<ContractResultBloc>();

    return BlocBuilder<ContractResultBloc, ContractResultState>(
      builder: (BuildContext context, ContractResultState state) {
        if (state.isScoringLoading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
        }

        // Sahifadagi `FailureView` xatoni guruhiga qarab yo'naltiradi, lekin
        // toast o'chib ketgach tab bo'sh qolmasligi kerak (5.8).
        final Failure? failure = state.scoringFailure;
        if (failure != null) {
          return ReportFailureView(failure: failure, onRetry: () => bloc.add(const ScoringRequested()));
        }

        if (!state.isScoringLoaded) return const SizedBox.shrink();

        if (state.results.isEmpty && state.flexMessages.isEmpty) {
          return const EmptyPlaceholder(
            icon: AppIcons.contract,
            title: "Ma'lumot topilmadi",
            message: "Ushbu shartnoma bo'yicha skoring natijasi yo'q",
          );
        }

        return ListView(
          padding: EdgeInsets.all(ScreenSize.h12),
          children: <Widget>[
            if (state.flexMessages.isNotEmpty) FlexMessagesCard(messages: state.flexMessages),
            ...state.results.map((ContractScoring item) => ScoringParticipant(scoring: item)),
          ],
        );
      },
    );
  }
}
