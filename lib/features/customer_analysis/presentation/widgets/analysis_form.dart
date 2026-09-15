import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/card_expiry_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/card_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/bloc/customer_analysis_bloc.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_issue_text.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Yangi tahlil so'rovi shakli: INPS, ixtiyoriy telefon va kengaytirilgan
/// (karta) bo'lim.
///
/// Nega qiymatlar bloc'da emas: ular faqat yuborishda kerak, har harfda
/// bloc holatini yangilash keraksiz qayta qurishga olib kelardi. Bloc'da
/// faqat yuborishdan keyin hisoblangan kamchilik (`issue`) turadi (7.5).
final class AnalysisForm extends StatefulWidget {
  const AnalysisForm({super.key, required this.showCardAdd});

  /// Kengaytirilgan (karta) bo'lim ko'rinadimi — `showScoringCard` huquqi.
  final bool showCardAdd;

  @override
  State<AnalysisForm> createState() => _AnalysisFormState();
}

final class _AnalysisFormState extends State<AnalysisForm> {
  final TextEditingController _inps = TextEditingController();
  final TextEditingController _contactPhone = TextEditingController();
  final TextEditingController _cardPhone = TextEditingController();
  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _cardExpiry = TextEditingController();

  bool _isAdvanced = false;

  @override
  void dispose() {
    _inps.dispose();
    _contactPhone.dispose();
    _cardPhone.dispose();
    _cardNumber.dispose();
    _cardExpiry.dispose();
    super.dispose();
  }

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  void _submit(BuildContext context) {
    context.read<CustomerAnalysisBloc>().add(
      AnalysisSubmitted(
        inps: _inps.text,
        contactPhone: _digits(_contactPhone.text),
        isAdvanced: _isAdvanced,
        card: AnalysisCardEntry(
          phone: _digits(_cardPhone.text),
          number: _digits(_cardNumber.text),
          expiry: _cardExpiry.text,
        ),
      ),
    );
  }

  void _clear() {
    _inps.clear();
    _contactPhone.clear();
    _cardPhone.clear();
    _cardNumber.clear();
    _cardExpiry.clear();
    setState(() => _isAdvanced = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerAnalysisBloc, CustomerAnalysisState>(
      listenWhen: (CustomerAnalysisState previous, CustomerAnalysisState current) =>
          current.submitted && !previous.submitted,
      listener: (BuildContext context, CustomerAnalysisState state) {
        _clear();
        context.read<CustomerAnalysisBloc>().add(const SubmittedShown());
      },
      builder: (BuildContext context, CustomerAnalysisState state) => Container(
        margin: EdgeInsets.fromLTRB(ScreenSize.h12, ScreenSize.h12, ScreenSize.h12, ScreenSize.h4),
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r20),
          border: Border.all(color: AppTheme.colors.black.withValues(alpha: .06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextInputWidget(
              title: AnalysisText.inpsLabel,
              hint: AnalysisText.inpsHint,
              controller: _inps,
              keyboardType: TextInputType.number,
              formatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(AnalysisRequest.inpsDigits),
              ],
              errorText: AnalysisIssueText.inps(state.issue),
            ),

            Gap(ScreenSize.h10),
            TextInputWidget(
              title: AnalysisText.contactPhoneLabel,
              hint: AnalysisText.phoneHint,
              prefix: '+998',
              controller: _contactPhone,
              keyboardType: TextInputType.phone,
              formatters: <TextInputFormatter>[PhoneFormatter()],
              errorText: AnalysisIssueText.contactPhone(state.issue),
            ),

            if (widget.showCardAdd) ...<Widget>[
              Gap(ScreenSize.h10),
              _advancedToggle(),

              if (_isAdvanced) ...<Widget>[
                Gap(ScreenSize.h10),
                TextInputWidget(
                  title: AnalysisText.cardPhoneLabel,
                  hint: AnalysisText.phoneHint,
                  prefix: '+998',
                  controller: _cardPhone,
                  keyboardType: TextInputType.phone,
                  formatters: <TextInputFormatter>[PhoneFormatter()],
                  errorText: AnalysisIssueText.cardPhone(state.issue),
                ),

                Gap(ScreenSize.h10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: TextInputWidget(
                        title: AnalysisText.cardNumberLabel,
                        hint: '0000 0000 0000 0000',
                        controller: _cardNumber,
                        keyboardType: TextInputType.number,
                        formatters: <TextInputFormatter>[CardFormatter()],
                        errorText: AnalysisIssueText.cardNumber(state.issue),
                      ),
                    ),

                    Gap(ScreenSize.w8),
                    Expanded(
                      flex: 2,
                      child: TextInputWidget(
                        title: AnalysisText.cardExpiryLabel,
                        hint: 'MM/YY',
                        controller: _cardExpiry,
                        keyboardType: TextInputType.number,
                        formatters: <TextInputFormatter>[CardExpiryFormatter()],
                        errorText: AnalysisIssueText.cardExpiry(state.issue),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            Gap(ScreenSize.h12),
            MainButton(
              text: AnalysisText.submit,
              showLoading: state.isSubmitting,
              onPressed: () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _advancedToggle() => InkWell(
    onTap: () => setState(() => _isAdvanced = !_isAdvanced),
    borderRadius: BorderRadius.circular(ScreenSize.r20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.w8, vertical: ScreenSize.h8),
      decoration: BoxDecoration(
        color: _isAdvanced ? AppTheme.colors.primary.withValues(alpha: .06) : AppTheme.colors.backcolor,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: Border.all(color: _isAdvanced ? AppTheme.colors.primary.withValues(alpha: .35) : Colors.transparent),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.tune_rounded,
            size: ScreenSize.h18,
            color: _isAdvanced ? AppTheme.colors.primary : AppTheme.colors.grey,
          ),

          Gap(ScreenSize.w8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  AnalysisText.advancedTitle,
                  style: AppTheme.data.textTheme.titleSmall?.copyWith(
                    color: AppTheme.colors.blackSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  AnalysisText.advancedSubtitle,
                  style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
                ),
              ],
            ),
          ),

          Icon(
            _isAdvanced ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: AppTheme.colors.grey,
          ),
        ],
      ),
    ),
  );
}
