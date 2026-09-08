import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/thousand_separator_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/manager_bonus.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bonus/manager_bonus_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bonus/bonus_issue_text.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/spoke_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Filial rahbari bonusi: tasdiqlash yoki rad etish.
final class ManagerBonusPage extends StatefulWidget {
  const ManagerBonusPage({super.key});

  @override
  State<ManagerBonusPage> createState() => _ManagerBonusPageState();
}

final class _ManagerBonusPageState extends State<ManagerBonusPage> {
  late final TextEditingController _amount;
  late final TextEditingController _comment;

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController();
    _comment = TextEditingController();
  }

  @override
  void dispose() {
    _amount.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ManagerBonusBloc, ManagerBonusState>(
      listenWhen: (ManagerBonusState previous, ManagerBonusState current) =>
          current.isSent && !previous.isSent,
      listener: (BuildContext context, ManagerBonusState state) =>
          context.pop(true),
      builder: (BuildContext context, ManagerBonusState state) {
        final ManagerBonusBloc bloc = context.read<ManagerBonusBloc>();
        final bool isApproving = state.form.decision == BonusDecision.approved;

        return SpokeScaffold(
          title: "Filial rahbari bonusi",
          failure: state.failure,
          failureHandled: () => bloc.add(const FailureHandled()),
          retryPress: () => bloc.add(const Retried()),
          backPress: () => context.pop(),
          bottom: MainButton(
            text: isApproving ? "Tasdiqlash" : "Rad etish",
            margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
            color: isApproving ? null : AppTheme.colors.red,
            showLoading: state.isSending,
            onPressed: () => bloc.add(const BonusSubmitted()),
          ),
          child: ListView(
            padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h16, ScreenSize.h16, ScreenSize.h24),
            children: <Widget>[
              _limits(state.benefit),
              Gap(ScreenSize.h14),

              Row(
                children: <Widget>[
                  Expanded(
                    child: _decision(
                      label: "Tasdiqlash",
                      isSelected: isApproving,
                      accent: AppTheme.colors.primary,
                      onTap: () => bloc.add(const BonusDecisionChanged(BonusDecision.approved)),
                    ),
                  ),
                  Gap(ScreenSize.w8),
                  Expanded(
                    child: _decision(
                      label: "Rad etish",
                      isSelected: !isApproving,
                      accent: AppTheme.colors.red,
                      onTap: () => bloc.add(const BonusDecisionChanged(BonusDecision.rejected)),
                    ),
                  ),
                ],
              ),

              // Rad etishda summa qo'llanmaydi — maydon ham chiqmaydi.
              if (isApproving) ...<Widget>[
                Gap(ScreenSize.h14),
                TextInputWidget(
                  title: "Bonus summasi",
                  hint: "0",
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  errorText: BonusIssueText.amount(state.issue),
                  formatters: <TextInputFormatter>[ThousandsSeparatorInputFormatter()],
                  onChanged: (String value) => bloc.add(BonusAmountChanged(Money.parse(value))),
                ),
              ],

              Gap(ScreenSize.h12),
              TextInputWidget(
                title: "Izoh",
                hint: "Sababini yozing",
                controller: _comment,
                errorText: BonusIssueText.comment(state.issue),
                onChanged: (String value) => bloc.add(BonusCommentChanged(value)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _limits(ContractBenefit benefit) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      border: AppSurface.border(),
    ),
    child: Column(
      children: <Widget>[
        _line("Talab qilingan", benefit.requiredAmount),
        _line("Mavjud limit", benefit.availableAmount),
        _line("Ishlatilgan", benefit.usedAmount),
      ],
    ),
  );

  Widget _line(String title, int amount) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h4),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(title, style: AppTheme.data.textTheme.bodySmall)),
        Text(
          Money.withUnit(amount),
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
        ),
      ],
    ),
  );

  Widget _decision({
    required String label,
    required bool isSelected,
    required Color accent,
    required VoidCallback onTap,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(ScreenSize.r14),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: ScreenSize.h14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? accent.withValues(alpha: .1) : AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r14),
        border: isSelected ? Border.all(color: accent) : AppSurface.border(),
      ),
      child: Text(
        label,
        style: AppTheme.data.textTheme.titleSmall?.copyWith(
          color: isSelected ? accent : AppTheme.colors.grey,
        ),
      ),
    ),
  );
}
