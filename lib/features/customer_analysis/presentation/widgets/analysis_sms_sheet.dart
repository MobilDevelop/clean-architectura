import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_text.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/bloc/customer_analysis_bloc.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// SMS kod bilan tasdiqlash.
///
/// Alohida bloc yaratilmaydi — ro'yxat bloci allaqachon shu yozuv bilan
/// ishlamoqda, xuddi fakturani ta'minotchiga yuborish kabi.
Future<void> showAnalysisSmsSheet({required BuildContext context, required CustomerAnalysis item}) => showAppSheet(
  context: context,
  child: BlocProvider<CustomerAnalysisBloc>.value(
    value: context.read<CustomerAnalysisBloc>(),
    child: _AnalysisSmsSheet(item: item),
  ),
);

final class _AnalysisSmsSheet extends StatefulWidget {
  const _AnalysisSmsSheet({required this.item});

  final CustomerAnalysis item;

  @override
  State<_AnalysisSmsSheet> createState() => _AnalysisSmsSheetState();
}

final class _AnalysisSmsSheetState extends State<_AnalysisSmsSheet> {
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerAnalysisBloc, CustomerAnalysisState>(
      listenWhen: (CustomerAnalysisState previous, CustomerAnalysisState current) =>
          current.confirmedId == widget.item.id && current.confirmedId != previous.confirmedId,
      listener: (BuildContext context, CustomerAnalysisState state) {
        context.read<CustomerAnalysisBloc>().add(const ConfirmedShown());
        Navigator.of(context).pop();
      },
      builder: (BuildContext context, CustomerAnalysisState state) {
        final bool isBusy = state.confirmingId == widget.item.id;
        final Failure? failure = state.failure;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                AnalysisText.smsTitle,
                style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
              ),

              Gap(ScreenSize.h8),
              Text(
                AnalysisText.smsSubtitle,
                textAlign: TextAlign.center,
                style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
              ),

              if (widget.item.phone.isNotEmpty) ...<Widget>[
                Gap(ScreenSize.h4),
                Text(
                  PhoneFormatter.mask(widget.item.phone),
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ],

              Gap(ScreenSize.h16),
              TextInputWidget(
                hint: AnalysisText.smsHint,
                controller: _code,
                enabled: !isBusy,
                autoFocus: true,
              ),

              if (failure != null) ...<Widget>[
                Gap(ScreenSize.h10),
                Text(
                  FailureText.of(failure),
                  textAlign: TextAlign.center,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.red),
                ),
              ],

              Gap(ScreenSize.h16),
              MainButton(
                text: AnalysisText.confirm,
                showLoading: isBusy,
                onPressed: () => context.read<CustomerAnalysisBloc>().add(
                  SmsConfirmSubmitted(item: widget.item, code: _code.text.trim()),
                ),
              ),

              Gap(ScreenSize.h8),
            ],
          ),
        );
      },
    );
  }
}
