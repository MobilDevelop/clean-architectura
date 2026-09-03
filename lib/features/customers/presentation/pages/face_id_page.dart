import 'dart:async';
import 'dart:io';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/sheets/date_sheet.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_form.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/face_id_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/face_check_issue_text.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/face_id_hint.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/offer_check.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/offer_sheet.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/passport_info_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Kamera keyingi bosqichda ulanadi — hozir tugma jimgina turmasligi uchun
/// holat ochiq aytiladi (5.8).
/// Taqvimda nechta yil orqaga qarash mumkin.
const int _yearSpan = 100;


final class FaceIdPage extends StatefulWidget {
  const FaceIdPage({super.key});

  @override
  State<FaceIdPage> createState() => _FaceIdPageState();
}

final class _FaceIdPageState extends State<FaceIdPage> {
  late final TextEditingController _seriesController;
  late final TextEditingController _numberController;
  late final TextEditingController _birthdayController;
  late final FocusNode _numberFocus;
  late final FaceIdBloc _bloc;

  @override
  void initState() {
    super.initState();
    _seriesController = TextEditingController();
    _numberController = TextEditingController();
    _birthdayController = TextEditingController();
    _numberFocus = FocusNode();
    _bloc = context.read<FaceIdBloc>();
  }

  @override
  void dispose() {
    _seriesController.dispose();
    _numberController.dispose();
    _birthdayController.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;

    return MultiBlocListener(
      listeners: <BlocListener<FaceIdBloc, FaceIdState>>[
        BlocListener<FaceIdBloc, FaceIdState>(
          listenWhen: (FaceIdState previous, FaceIdState current) => current.cameraOpen,
          listener: (BuildContext context, FaceIdState state) => unawaited(_openCamera()),
        ),

        BlocListener<FaceIdBloc, FaceIdState>(
          listenWhen: (FaceIdState previous, FaceIdState current) => current.customerInfo != previous.customerInfo,
          listener: (BuildContext context, FaceIdState state) {
            final CustomerInfo? customer = state.customerInfo;
            if (customer != null) context.pop(customer);
          },
        ),
      ],
      child: BlocSelector<FaceIdBloc, FaceIdState, Failure?>(
        selector: (FaceIdState state) => state.failure,
        builder: (BuildContext context, Failure? failure) => FailureView(
          failure: failure,
          onHandled: () => _bloc.add(const FailureHandled()),
          onRetry: () => _bloc.add(const CheckRetried()),
          bottomInset: ScreenSize.h90,
          child: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            body: Stack(
              children: <Widget>[
                const BackgroundWash(),

                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: topInset + ScreenSize.h56 + ScreenSize.h20,
                      left: ScreenSize.h16,
                      right: ScreenSize.h16,
                      bottom: ScreenSize.h40,
                    ),
                    child: BlocSelector<FaceIdBloc, FaceIdState, FaceCheckIssue>(
                      selector: (FaceIdState state) => state.issue,
                      builder: (BuildContext context, FaceCheckIssue issue) => Column(
                        children: <Widget>[
                          const FaceIdHint(),
                          Gap(ScreenSize.h24),
                          PassportInfoInput(
                            seriesController: _seriesController,
                            numberController: _numberController,
                            birthdayController: _birthdayController,
                            numberFocus: _numberFocus,
                            seriesError: FaceCheckIssueText.series(issue),
                            numberError: FaceCheckIssueText.number(issue),
                            birthdayError: FaceCheckIssueText.birthday(issue),
                            onSeriesChanged: _seriesChanged,
                            onNumberChanged: (String value) => _bloc.add(NumberChanged(value)),
                            onBirthdayChanged: (String value) => _bloc.add(BirthdayChanged(value)),
                            pickDate: () => unawaited(_pickDate()),
                          ),

                          Gap(ScreenSize.h20),
                          BlocSelector<FaceIdBloc, FaceIdState, bool>(
                            selector: (FaceIdState state) => state.isOfferAccepted,
                            builder: (BuildContext context, bool isAccepted) => OfferCheck(
                              isAccepted: isAccepted,
                              errorText: FaceCheckIssueText.offer(issue),
                              onOpen: () => unawaited(
                                showOfferSheet(context: context, onAccepted: () => _bloc.add(const OfferAccepted(true))),
                              ),
                              onCancel: () => _bloc.add(const OfferAccepted(false)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: PageHeader(title: "Mijozni tekshirish", topInset: topInset, backPress: context.pop),
                ),
              ],
            ),

            bottomNavigationBar: SafeArea(
              minimum: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h12),
              // Tugma o'chirilmaydi: bosilganda oferta tasdiqlanmagani katakcha
              // tagida yoziladi, ya'ni sabab ko'rinadi (5.8).
              child: BlocSelector<FaceIdBloc, FaceIdState, bool>(
                selector: (FaceIdState state) => state.isLoading,
                builder: (BuildContext context, bool isLoading) => MainButton(
                  text: "Rasmga olish",
                  showLoading: isLoading,
                  onPressed: () => _bloc.add(const CaptureRequested()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Kamera alohida ekran: rasm olingandan keyin qaytadi.
  Future<void> _openCamera() async {
    final File? photo = await context.push<File>(Routes.faceCamera.path);
    if (!mounted) return;

    _bloc.add(photo == null ? const CaptureCancelled() : PhotoCaptured(photo));
  }

  /// Seriya to'lgach fokus raqamga o'tadi — foydalanuvchi qo'l bilan bosmaydi.
  void _seriesChanged(String value) {
    _bloc.add(SeriesChanged(value));
    if (value.length == CustomerSearchShape.passportLetters) _numberFocus.requestFocus();
  }

  Future<void> _pickDate() {
    // Klaviatura ochiq qolsa taqvimni yopib turadi.
    FocusScope.of(context).unfocus();

    // Chegara domainda hisoblanadi — 16 yosh qoidasi bitta joyda turadi.
    final DateTime latest = FaceCheckForm.latestBirthday(DateTime.now());

    return showDateSheet(
      context: context,
      title: "Tug'ilgan sana",
      subtitle: "Kunni tanlang",
      date: _bloc.state.form.birthdayDate,
      firstDate: DateTime(latest.year - _yearSpan, latest.month, latest.day),
      lastDate: latest,
      viewMode: CalendarDatePicker2Mode.year,
      confirmText: "Tanlash",
      onPicked: _dateSelected,
    );
  }

  void _dateSelected(DateTime picked) {
    final String text = "${_two(picked.day)}.${_two(picked.month)}.${picked.year}";
    _birthdayController.text = text;
    _bloc.add(BirthdayChanged(text));
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
