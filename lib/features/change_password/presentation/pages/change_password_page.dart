import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/change_password/presentation/bloc/change_password_bloc.dart';
import 'package:colloborator_v3/features/change_password/presentation/styles/change_password_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// «Parolni o'zgartirish» — drawerdan ochiladigan ekran.
final class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

final class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmation = false;

  late final ChangePasswordBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<ChangePasswordBloc>();
  }

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _submit() =>
      _bloc.add(ChangePasswordSubmitted(password: _password.text, confirmation: _confirmation.text));

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return BlocSelector<ChangePasswordBloc, ChangePasswordState, Failure?>(
      selector: (ChangePasswordState state) => state.failure,
      builder: (BuildContext context, Failure? failure) => FailureView(
        failure: failure,
        onHandled: () => _bloc.add(const FailureHandled()),
        onRetry: () => _bloc.add(const Retried()),
        bottomInset: ScreenSize.h24,
        child: Scaffold(
          backgroundColor: AppTheme.colors.backcolor,
          body: Stack(
            children: <Widget>[
              const BackgroundWash(),

              Positioned.fill(
                child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
                  builder: (BuildContext context, ChangePasswordState state) => _content(state, topInset),
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: PageHeader(title: ChangePasswordText.title, topInset: topInset, backPress: context.pop),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(ChangePasswordState state, double topInset) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        ScreenSize.h16,
        topInset + ScreenSize.h56 + ScreenSize.h12,
        ScreenSize.h16,
        ScreenSize.h24,
      ),
      children: <Widget>[
        TextInputWidget(
          title: ChangePasswordText.passwordLabel,
          hint: ChangePasswordText.passwordHint,
          controller: _password,
          isPassword: !_showPassword,
          suffixIcon: _showPassword ? AppIcons.eyeClose : AppIcons.eyeOpen,
          errorText: PasswordIssueText.password(state.issue),
          onChanged: (_) {},
          suffixPress: () => setState(() => _showPassword = !_showPassword),
        ),

        Gap(ScreenSize.h16),
        TextInputWidget(
          title: ChangePasswordText.confirmationLabel,
          hint: ChangePasswordText.confirmationHint,
          controller: _confirmation,
          isPassword: !_showConfirmation,
          suffixIcon: _showConfirmation ? AppIcons.eyeClose : AppIcons.eyeOpen,
          errorText: PasswordIssueText.confirmation(state.issue),
          onChanged: (_) {},
          suffixPress: () => setState(() => _showConfirmation = !_showConfirmation),
        ),

        Gap(ScreenSize.h20),
        MainButton(text: ChangePasswordText.submit, showLoading: state.isSubmitting, onPressed: _submit),
      ],
    );
  }
}
