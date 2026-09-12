import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/card_expiry_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/card_formatter.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/card_confirmation.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/card_confirm_state.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/card_confirm_text.dart';
import 'package:colloborator_v3/core/widgets/feedback/sms_countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Shartnomaga qo'shilgan kartani tasdiqlaydi (ELMA OTP).
///
/// `onCancelRequested` — karta boshqa shaxsniki bo'lgan holat: ELMA OTP
/// yubormaydi va server har qanday davom etishni rad etadi, ya'ni yagona yo'l
/// shartnomani bekor qilish. Bekor qilishning o'zi amallar oynasida —
/// tasdiq dialogi va xato yuzasi bir joyda tursin.
Future<void> showCardConfirmSheet({
  required BuildContext context,
  required int contractId,
  required VoidCallback onConfirmed,
  required VoidCallback onCancelRequested,
}) => showAppSheet(
  context: context,
  child: BlocProvider<CardConfirmBloc>(
    create: (BuildContext context) =>
        getIt<CardConfirmBloc>(param1: contractId)..add(const CardConfirmRequested()),
    child: CardConfirmSheet(onConfirmed: onConfirmed, onCancelRequested: onCancelRequested),
  ),
);

final class CardConfirmSheet extends StatefulWidget {
  const CardConfirmSheet({super.key, required this.onConfirmed, required this.onCancelRequested});

  final VoidCallback onConfirmed;
  final VoidCallback onCancelRequested;

  @override
  State<CardConfirmSheet> createState() => _CardConfirmSheetState();
}

final class _CardConfirmSheetState extends State<CardConfirmSheet> {
  final TextEditingController _code = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  /// Hisoblagich nolga yetdi — kodni qayta yuborish mumkin.
  bool _isExpired = false;

  @override
  void dispose() {
    _code.dispose();
    _number.dispose();
    _expiry.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _syncEntry(CardConfirmBloc bloc) => bloc.add(
    CardEntryChanged(
      CardEntry(
        number: _digits(_number.text),
        expiry: _expiry.text,
        phone: _digits(_phone.text),
      ),
    ),
  );

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CardConfirmBloc, CardConfirmState>(
      listenWhen: (CardConfirmState previous, CardConfirmState current) =>
          current.isDone && !previous.isDone,
      listener: (BuildContext context, CardConfirmState state) {
        context.pop();
        widget.onConfirmed();
      },
      builder: (BuildContext context, CardConfirmState state) {
        final CardConfirmBloc bloc = context.read<CardConfirmBloc>();

        return SizedBox(
          height: MediaQuery.sizeOf(context).height * .75,
          child: FailureView(
            failure: state.failure,
            onHandled: () => bloc.add(const FailureHandled()),
            onRetry: () => bloc.add(const Retried()),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
              child: Column(
                children: <Widget>[
                  Text(
                    CardConfirmText.title,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),

                  Gap(ScreenSize.h12),
                  Expanded(child: _body(state, bloc)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(CardConfirmState state, CardConfirmBloc bloc) {
    if (state.isLoading && state.data == null) {
      return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
    }

    final CardConfirmation? data = state.data;

    if (data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(CardConfirmText.loadFailed, style: AppTheme.data.textTheme.bodySmall),

            Gap(ScreenSize.h12),
            SizedBox(
              width: ScreenSize.h160,
              child: MainButton(
                text: CardConfirmText.retry,
                showLoading: state.isLoading,
                onPressed: () => bloc.add(const CardConfirmRequested()),
              ),
            ),
          ],
        ),
      );
    }

    // Karta boshqa shaxsniki: OTP maydoni ham, «Tasdiqlash» ham chizilmaydi —
    // xodimga ishlamaydigan tugma ko'rsatishning ma'nosi yo'q.
    if (data.isOwnerMismatch) return _mismatch(data);

    return state.needsCard ? _cardForm(state, bloc) : _codeForm(state, data, bloc);
  }

  Widget _mismatch(CardConfirmation data) => Column(
    children: <Widget>[
      Gap(ScreenSize.h24),
      Container(
        padding: EdgeInsets.all(ScreenSize.h16),
        decoration: BoxDecoration(color: AppTheme.colors.red.withValues(alpha: .1), shape: BoxShape.circle),
        child: SvgPicture.asset(
          AppIcons.warning,
          height: ScreenSize.h28,
          colorFilter: ColorFilter.mode(AppTheme.colors.red, BlendMode.srcIn),
        ),
      ),

      Gap(ScreenSize.h16),
      Text(
        CardConfirmText.mismatchTitle,
        textAlign: TextAlign.center,
        style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.black),
      ),

      // Sabab matni backenddan keladi va faqat o'sha yerda yangilanadi.
      if (data.message.isNotEmpty) ...<Widget>[
        Gap(ScreenSize.h10),
        Text(
          data.message,
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.red),
        ),
      ],

      const Spacer(),
      MainButton(
        text: CardConfirmText.cancelContract,
        color: AppTheme.colors.red,
        onPressed: () {
          context.pop();
          widget.onCancelRequested();
        },
      ),

      Gap(ScreenSize.h8),
    ],
  );

  Widget _codeForm(CardConfirmState state, CardConfirmation data, CardConfirmBloc bloc) {
    final DateTime? expiresAt = data.expiresAt;

    // Kodni qayta yuborish: server shuni so'ragan bo'lsa yoki muddat tugagan
    // bo'lsa. Sana kelmagan bo'lsa ham ko'rsatiladi — aks holda xodim
    // hisoblagichsiz ekranda hech nima qila olmasdi.
    final bool canResend =
        data.step == CardConfirmStep.resend || expiresAt == null || _isExpired;

    return Column(
      children: <Widget>[
        Text(
          CardConfirmText.sentTo(PhoneFormatter.mask(data.phone)),
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h16),
        TextInputWidget(
          hint: CardConfirmText.codeHint,
          controller: _code,
          enabled: !state.isSkipCard && !state.isBusy,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(6)],
          onChanged: (String value) => bloc.add(CodeChanged(value)),
        ),

        Gap(ScreenSize.h14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(CardConfirmText.waiting, style: AppTheme.data.textTheme.titleSmall),

            Gap(ScreenSize.w10),
            if (canResend)
              InkWell(
                onTap: state.isBusy ? null : () => bloc.add(const CodeResendRequested()),
                child: Text(
                  CardConfirmText.resend,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blue),
                ),
              )
            else
              SmsCountdown(
                expiresAt: expiresAt,
                onExpired: () => setState(() => _isExpired = true),
              ),
          ],
        ),

        if (data.message.isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h10),
          Text(
            data.message,
            textAlign: TextAlign.center,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.red),
          ),
        ],

        Gap(ScreenSize.h8),
        _skipCheck(state, bloc),

        const Spacer(),
        MainButton(
          text: CardConfirmText.submit,
          showLoading: state.isSubmitting,
          onPressed: () => bloc.add(const CardConfirmSubmitted()),
        ),

        Gap(ScreenSize.h8),
      ],
    );
  }

  Widget _cardForm(CardConfirmState state, CardConfirmBloc bloc) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          CardConfirmText.cardTitle,
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          title: CardConfirmText.cardNumber,
          hint: '8600 0000 0000 0000',
          controller: _number,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[CardFormatter()],
          onChanged: (_) => _syncEntry(bloc),
        ),

        Gap(ScreenSize.h10),
        TextInputWidget(
          title: CardConfirmText.cardExpiry,
          hint: 'MM/YY',
          controller: _expiry,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[CardExpiryFormatter()],
          onChanged: (_) => _syncEntry(bloc),
        ),

        Gap(ScreenSize.h10),
        TextInputWidget(
          title: CardConfirmText.cardPhone,
          hint: '+998',
          controller: _phone,
          keyboardType: TextInputType.phone,
          formatters: <TextInputFormatter>[PhoneFormatter()],
          onChanged: (_) => _syncEntry(bloc),
        ),

        Gap(ScreenSize.h10),
        _skipCheck(state, bloc),

        Gap(ScreenSize.h12),
        MainButton(
          text: CardConfirmText.submit,
          showLoading: state.isSubmitting,
          onPressed: () => bloc.add(const CardConfirmSubmitted()),
        ),

        Gap(ScreenSize.h8),
      ],
    ),
  );

  Widget _skipCheck(CardConfirmState state, CardConfirmBloc bloc) => Row(
    children: <Widget>[
      Checkbox(
        value: state.isSkipCard,
        checkColor: AppTheme.colors.white,
        activeColor: AppTheme.colors.primary,
        onChanged: state.isBusy ? null : (_) => bloc.add(const SkipCardToggled()),
      ),

      Expanded(
        child: Text(
          CardConfirmText.skipCard,
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
        ),
      ),
    ],
  );
}
