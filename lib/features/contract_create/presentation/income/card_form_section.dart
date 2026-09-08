import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/card_expiry_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/card_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/card_issue_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Faqat raqamlar — bloc formatlangan matnni emas, raqamlarni saqlaydi.
String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Karta aylanmasi bloki: qo'shish formasi yoki biriktirilgan karta.
final class CardFormSection extends StatelessWidget {
  const CardFormSection({
    super.key,
    required this.card,
    required this.issue,
    required this.isBusy,
    required this.isEnabled,
    required this.disabledReason,
    required this.phoneController,
    required this.numberController,
    required this.expiryController,
    required this.phoneFocus,
    required this.numberFocus,
    required this.expiryFocus,
    required this.fieldChanged,
    required this.submitPress,
    required this.removePress,
  });

  /// Serverdagi karta. Bo'sh bo'lsa forma ko'rsatiladi.
  final ContractCard card;

  final CardFieldIssue issue;
  final bool isBusy;

  /// Karta qo'shish mumkinmi.
  final bool isEnabled;

  /// Mumkin bo'lmasa — sababi.
  final String disabledReason;

  final TextEditingController phoneController;
  final TextEditingController numberController;
  final TextEditingController expiryController;

  /// Maydon to'lganda keyingisiga o'tish uchun.
  final FocusNode phoneFocus;
  final FocusNode numberFocus;
  final FocusNode expiryFocus;

  final void Function({String? phone, String? number, String? expiry}) fieldChanged;
  final VoidCallback submitPress;
  final VoidCallback removePress;

  @override
  Widget build(BuildContext context) => card.isEmpty ? _form(context) : _card(context);

  Widget _card(BuildContext context) => Container(
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      border: AppSurface.border(),
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _maskNumber(card.number),
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
              ),
              Gap(ScreenSize.h2),
              Text(
                "${PhoneFormatter.mask(card.phone)}${card.expiry.isEmpty ? '' : ' · ${card.expiry}'}",
                style: AppTheme.data.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        if (isBusy)
          SizedBox(
            width: ScreenSize.h34,
            height: ScreenSize.h34,
            child: Center(
              child: SizedBox(
                width: ScreenSize.h18,
                height: ScreenSize.h18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
              ),
            ),
          )
        else
          InkWell(
            onTap: removePress,
            borderRadius: BorderRadius.circular(ScreenSize.r12),
            child: Container(
              width: ScreenSize.h34,
              height: ScreenSize.h34,
              decoration: BoxDecoration(
                color: AppTheme.colors.red.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(ScreenSize.r12),
              ),
              child: Icon(Icons.delete_outline, size: ScreenSize.h18, color: AppTheme.colors.red),
            ),
          ),
      ],
    ),
  );

  Widget _form(BuildContext context) {
    if (!isEnabled) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.backcolor,
          borderRadius: BorderRadius.circular(ScreenSize.r18),
          border: AppSurface.border(alpha: .5),
        ),
        child: Text(disabledReason, style: AppTheme.data.textTheme.bodySmall),
      );
    }

    return Column(
      children: <Widget>[
        // Maydon to'lgach fokus o'zi keyingisiga o'tadi: uchta maydonni
        // qo'lda bosib chiqish klaviaturani har safar yopadi.
        TextInputWidget(
          title: "Telefon raqami",
          hint: "+998 __ ___-__-__",
          controller: phoneController,
          focusNode: phoneFocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          errorText: CardIssueText.phone(issue),
          formatters: <TextInputFormatter>[PhoneFormatter()],
          onChanged: (String value) => _advance(
            value: value,
            filled: CardForm.phoneDigits,
            next: numberFocus,
            report: (String digits) => fieldChanged(phone: digits),
          ),
          onSubmitted: (_) => numberFocus.requestFocus(),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: "Karta raqami",
          hint: "____ ____ ____ ____",
          controller: numberController,
          focusNode: numberFocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          errorText: CardIssueText.number(issue),
          formatters: <TextInputFormatter>[CardFormatter()],
          onChanged: (String value) => _advance(
            value: value,
            filled: CardForm.numberDigits,
            next: expiryFocus,
            report: (String digits) => fieldChanged(number: digits),
          ),
          onSubmitted: (_) => expiryFocus.requestFocus(),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: "Amal qilish muddati",
          hint: "MM/YY",
          controller: expiryController,
          focusNode: expiryFocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          errorText: CardIssueText.expiry(issue),
          formatters: <TextInputFormatter>[CardExpiryFormatter()],
          onChanged: (String value) => _advance(
            value: value,
            filled: CardForm.expiryDigits,
            next: null,
            report: (String digits) => fieldChanged(expiry: digits),
          ),
        ),

        Gap(ScreenSize.h16),
        MainButton(text: "Kartani biriktirish", showLoading: isBusy, onPressed: submitPress),
      ],
    );
  }

  /// Qiymatni bloc'ga uzatadi va maydon to'lgan bo'lsa keyingisiga o'tadi.
  ///
  /// Chegara domaindan olinadi — bu yerda takrorlansa, ikkalasi vaqt o'tib
  /// bir-biridan uzoqlashadi.
  void _advance({
    required String value,
    required int filled,
    required FocusNode? next,
    required ValueChanged<String> report,
  }) {
    final String digits = _digits(value);

    report(digits);

    if (digits.length >= filled) next?.requestFocus();
  }

  /// `8600 **** **** 1234`.
  String _maskNumber(String number) {
    if (number.length < 8) return number;

    return "${number.substring(0, 4)} **** **** ${number.substring(number.length - 4)}";
  }
}
