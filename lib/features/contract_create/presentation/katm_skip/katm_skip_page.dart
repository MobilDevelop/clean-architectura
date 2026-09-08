import 'dart:async';

import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/katm_skip.dart';
import 'package:colloborator_v3/features/contract_create/presentation/katm_skip/katm_skip_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/katm_skip/katm_skip_issue_text.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/option_sheet.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/spoke_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// KATM/MIB tekshiruvini o'tkazib yuborish.
///
/// Ekranning tepasida nega ochilgani turadi — serverdan kelgan rad etish
/// sabablari. Flex ularni shartnoma ekranining o'rtasiga yashirardi.
final class KatmSkipPage extends StatefulWidget {
  const KatmSkipPage({super.key});

  @override
  State<KatmSkipPage> createState() => _KatmSkipPageState();
}

final class _KatmSkipPageState extends State<KatmSkipPage> {
  late final TextEditingController _comment;

  @override
  void initState() {
    super.initState();
    _comment = TextEditingController();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _pickReason(BuildContext context, KatmSkipState state) {
    final KatmSkipBloc bloc = context.read<KatmSkipBloc>();

    return showOptionSheet<SkipReason>(
      context: context,
      title: "Sabab turi",
      options: state.reasons,
      labelOf: (SkipReason e) => e.name,
      isSelected: (SkipReason e) => e.id == state.form.reason.id,
      onPicked: (SkipReason e) => bloc.add(ReasonSelected(e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KatmSkipBloc, KatmSkipState>(
      listenWhen: (KatmSkipState previous, KatmSkipState current) => current.isDone && !previous.isDone,
      listener: (BuildContext context, KatmSkipState state) =>
          context.pop(true),
      builder: (BuildContext context, KatmSkipState state) {
        final KatmSkipBloc bloc = context.read<KatmSkipBloc>();

        return SpokeScaffold(
          title: "KATM/MIB tekshiruvi",
          failure: state.failure,
          failureHandled: () => bloc.add(const FailureHandled()),
          retryPress: () => bloc.add(const Retried()),
          backPress: () => context.pop(),
          isLoading: state.isLoading && !state.isLoaded,
          bottom: MainButton(
            text: "Tekshiruvni o'tkazib yuborish",
            margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
            showLoading: state.isSending,
            onPressed: () => bloc.add(const SkipSubmitted()),
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h16, ScreenSize.h16, ScreenSize.h24),
            children: <Widget>[
              if (state.hasFailReasons) ...<Widget>[
                _reasons(state),
                Gap(ScreenSize.h14),
              ],

              SelectTile(
                title: "Sabab turi",
                hint: "Tanlang",
                value: state.form.reason.name,
                errorText: KatmSkipIssueText.reason(state.issue),
                onTap: () => unawaited(_pickReason(context, state)),
              ),

              Gap(ScreenSize.h12),
              TextInputWidget(
                title: "Izoh",
                hint: "Sababini batafsil yozing",
                controller: _comment,
                errorText: KatmSkipIssueText.comment(state.issue),
                onChanged: (String value) => bloc.add(CommentChanged(value)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reasons(KatmSkipState state) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.red.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      border: AppSurface.border(alpha: .5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "Nega tekshiruvdan o'tmadi",
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        if (state.katmFailReason.isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h6),
          Text("KATM: ${state.katmFailReason}", style: AppTheme.data.textTheme.bodySmall),
        ],

        if (state.mibFailReason.isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h4),
          Text("MIB: ${state.mibFailReason}", style: AppTheme.data.textTheme.bodySmall),
        ],
      ],
    ),
  );
}
