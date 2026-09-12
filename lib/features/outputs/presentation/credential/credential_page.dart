import 'dart:async';

import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/select_tile.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/option_sheet.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/presentation/credential/box_choice.dart';
import 'package:colloborator_v3/features/outputs/presentation/credential/credential_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/credential/credential_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Bitta qurilmaning iCloud ma'lumotlari.
final class CredentialPage extends StatefulWidget {
  const CredentialPage({super.key});

  @override
  State<CredentialPage> createState() => _CredentialPageState();
}

final class _CredentialPageState extends State<CredentialPage> {
  final TextEditingController _condition = TextEditingController();
  final TextEditingController _imei = TextEditingController();
  final TextEditingController _imei2 = TextEditingController();
  final TextEditingController _serial = TextEditingController();
  final TextEditingController _login = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _restriction = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  late final CredentialBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<CredentialBloc>();

    // Serverdan kelgan raqamlar maydonga tayyor holda tushadi va ular
    // o'zgartirilmaydi: raqam yorliqdan o'qilgan, qo'lda qayta yozish xato
    // kiritishning yo'li.
    final IcloudCredential credential = _bloc.state.credential;
    _imei.text = credential.imei;
    _imei2.text = credential.imei2;
  }

  @override
  void dispose() {
    _condition.dispose();
    _imei.dispose();
    _imei2.dispose();
    _serial.dispose();
    _login.dispose();
    _password.dispose();
    _restriction.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _edit(CredentialField field, String value) => _bloc.add(CredentialFieldChanged(field, value));

  Future<void> _pickOwner({required bool isLogin, required AppleIdOwner? current}) => showOptionSheet<AppleIdOwner>(
    context: context,
    title: isLogin ? CredentialText.appleLogin : CredentialText.applePassword,
    options: AppleIdOwner.values,
    labelOf: CredentialText.owner,
    isSelected: (AppleIdOwner value) => value == current,
    onPicked: (AppleIdOwner value) =>
        _bloc.add(isLogin ? AppleLoginSelected(value) : ApplePasswordSelected(value)),
  );

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return BlocConsumer<CredentialBloc, CredentialState>(
      listenWhen: (CredentialState previous, CredentialState current) =>
          current.isSaved && !previous.isSaved,
      listener: (BuildContext context, CredentialState state) => context.pop(true),
      builder: (BuildContext context, CredentialState state) => FailureView(
        failure: state.failure,
        onHandled: () => _bloc.add(const FailureHandled()),
        onRetry: () => _bloc.add(const Retried()),
        bottomInset: ScreenSize.h80,
        child: Scaffold(
          backgroundColor: AppTheme.colors.backcolor,
          body: Stack(
            children: <Widget>[
              const BackgroundWash(),

              Positioned.fill(child: _form(state, topInset + ScreenSize.h56)),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PageHeader(
                  title: CredentialText.title,
                  topInset: topInset,
                  backPress: context.pop,
                ),
              ),
            ],
          ),

          bottomNavigationBar: SafeArea(
            minimum: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h12),
            child: MainButton(
              text: CredentialText.save,
              showLoading: state.isSaving,
              onPressed: () => _bloc.add(const CredentialSubmitted()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form(CredentialState state, double topPadding) {
    final IcloudCredential credential = state.credential;
    final IcloudIssue issue = state.issue;
    final bool hasImei = state.device.imei.isNotEmpty;
    final bool hasImei2 = state.device.imei2.isNotEmpty;

    return ListView(
      padding: EdgeInsets.only(
        top: topPadding + ScreenSize.h12,
        left: ScreenSize.h16,
        right: ScreenSize.h16,
        bottom: ScreenSize.h24,
      ),
      children: <Widget>[
        _device(state),

        Gap(ScreenSize.h14),
        TextInputWidget(
          title: CredentialText.condition,
          hint: CredentialText.conditionHint,
          controller: _condition,
          errorText: CredentialText.of(issue, IcloudIssue.conditionMissing),
          textInputAction: TextInputAction.next,
          onChanged: (String value) => _edit(CredentialField.condition, value),
        ),

        Gap(ScreenSize.h12),
        BoxChoice(
          title: CredentialText.box,
          yesLabel: CredentialText.boxYes,
          noLabel: CredentialText.boxNo,
          value: credential.hasBox,
          errorText: CredentialText.of(issue, IcloudIssue.boxMissing),
          onChanged: (bool value) => _bloc.add(BoxSelected(value)),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.imei,
          hint: CredentialText.imeiHint,
          controller: _imei,
          enabled: !hasImei,
          errorText: CredentialText.of(issue, IcloudIssue.imeiShort),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(IcloudCredential.imeiLength),
          ],
          onChanged: (String value) => _edit(CredentialField.imei, value),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.imei2,
          hint: CredentialText.imei2Hint,
          controller: _imei2,
          enabled: !hasImei2,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(IcloudCredential.imeiLength),
          ],
          onChanged: (String value) => _edit(CredentialField.imei2, value),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.serial,
          hint: CredentialText.serialHint,
          controller: _serial,
          errorText: CredentialText.of(issue, IcloudIssue.serialMissing),
          textInputAction: TextInputAction.next,
          onChanged: (String value) => _edit(CredentialField.serialNumber, value),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.login,
          hint: CredentialText.loginHint,
          controller: _login,
          errorText: CredentialText.of(issue, IcloudIssue.loginMissing),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (String value) => _edit(CredentialField.login, value),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.password,
          hint: CredentialText.passwordHint,
          controller: _password,
          errorText: CredentialText.of(issue, IcloudIssue.passwordMissing),
          textInputAction: TextInputAction.next,
          onChanged: (String value) => _edit(CredentialField.password, value),
        ),

        Gap(ScreenSize.h12),
        SelectTile(
          title: CredentialText.appleLogin,
          hint: CredentialText.ownerHint,
          value: _ownerLabel(credential.appleLogin),
          errorText: CredentialText.of(issue, IcloudIssue.appleLoginMissing),
          onTap: () => unawaited(_pickOwner(isLogin: true, current: credential.appleLogin)),
        ),

        Gap(ScreenSize.h12),
        SelectTile(
          title: CredentialText.applePassword,
          hint: CredentialText.ownerHint,
          value: _ownerLabel(credential.applePassword),
          errorText: CredentialText.of(issue, IcloudIssue.applePasswordMissing),
          onTap: () => unawaited(_pickOwner(isLogin: false, current: credential.applePassword)),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.restriction,
          hint: CredentialText.restrictionHint,
          controller: _restriction,
          errorText: CredentialText.of(issue, IcloudIssue.restrictionShort),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          formatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(IcloudCredential.restrictionLength),
          ],
          onChanged: (String value) => _edit(CredentialField.restrictionCode, value),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          title: CredentialText.phone,
          hint: CredentialText.phoneHint,
          controller: _phone,
          errorText: CredentialText.of(issue, IcloudIssue.phoneShort),
          keyboardType: TextInputType.phone,
          formatters: <TextInputFormatter>[PhoneFormatter()],
          // Maskadagi qavs va chiziqlar serverga ketmaydi.
          onChanged: (String value) => _edit(CredentialField.phone, _digits(value)),
        ),
      ],
    );
  }

  String _ownerLabel(AppleIdOwner? owner) => owner == null ? '' : CredentialText.owner(owner);

  String _digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  /// Qaysi qurilma to'ldirilayotgani forma tepasida turadi: xodim bir necha
  /// qurilma orasida adashmasligi kerak.
  Widget _device(CredentialState state) => Container(
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      border: AppSurface.border(),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          state.device.name,
          style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.black),
        ),

        if (state.device.fullName.isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h2),
          Text(state.device.fullName, style: AppTheme.data.textTheme.bodySmall),
        ],

        Gap(ScreenSize.h8),
        Row(
          children: <Widget>[
            Text(
              "${CredentialText.client}: ",
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey),
            ),

            Expanded(
              child: Text(
                state.clientName,
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
