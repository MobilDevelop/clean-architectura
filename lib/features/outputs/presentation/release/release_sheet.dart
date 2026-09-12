import 'dart:io';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/di/injection.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/camera_issue.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/feedback/sms_countdown.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/product_photo_field.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_bloc.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// SMS kodning amal qilish muddati. Server kodni shartnoma holati
/// o'zgarganda yuboradi, ya'ni sanash `updated_at` dan boshlanadi.
const Duration _smsWindow = Duration(minutes: 5);

/// Oyna nima bilan yopildi.
enum ReleaseOutcome {
  /// Xodim oynani yopdi.
  closed,

  /// Chiqim berildi.
  released,

  /// iCloud ma'lumotlari to'ldirilishi kerak — chaqiruvchi talablar
  /// oynasini ochadi.
  requirementsNeeded,
}

/// Chiqim berish oynasini ochadi.
///
/// Talablar oynasi bu yerdan ochilmaydi: modal oynaning **ustiga** sahifa
/// qo'yish `go_router` ning sahifalar ro'yxati bilan imperativ marshrutni
/// aralashtiradi. Ilovadagi qolip — avval oynani yopish, keyin o'tish
/// (`contract_action_sheet` ham shunday qiladi).
Future<ReleaseOutcome> showReleaseSheet({
  required BuildContext context,
  required OutputContract contract,
}) async {
  final ReleaseOutcome? outcome = await showAppSheet<ReleaseOutcome>(
    context: context,
    child: BlocProvider<ReleaseBloc>(
      create: (BuildContext context) => getIt<ReleaseBloc>(param1: contract)..add(const ReleaseStarted()),
      child: const ReleaseSheet(),
    ),
  );

  return outcome ?? ReleaseOutcome.closed;
}

final class ReleaseSheet extends StatefulWidget {
  const ReleaseSheet({super.key});

  @override
  State<ReleaseSheet> createState() => _ReleaseSheetState();
}

final class _ReleaseSheetState extends State<ReleaseSheet> {
  final TextEditingController _code = TextEditingController();

  /// Hisoblagich nolga yetdi — endi «adminga murojaat qiling» ko'rinadi.
  bool _isExpired = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  /// Kamera ochish — UI ta'siri, u bloc ichida bo'lmaydi (6.2).
  ///
  /// O'lcham va sifat shu yerda chegaralanadi: kameradan kelgan original
  /// 3-8 MB bo'ladi va uni multipart bilan yuborish sekin aloqada oynani
  /// qotirib qo'yardi.
  Future<void> _takePhoto(ReleaseBloc bloc) async {
    final XFile? shot;

    try {
      shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
    } on PlatformException catch (e) {
      if (mounted) bloc.add(CameraRefused(CameraIssues.of(e)));
      return;
    } catch (_) {
      if (mounted) bloc.add(const CameraRefused(CameraIssue.unknown));
      return;
    }

    // Bekor qilish — xato emas: foydalanuvchi o'zi qaytdi.
    if (shot == null || !mounted) return;

    bloc.add(PhotoTaken(File(shot.path)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReleaseBloc, ReleaseState>(
      listenWhen: (ReleaseState previous, ReleaseState current) => current.isDone && !previous.isDone,
      listener: (BuildContext context, ReleaseState state) => context.pop(ReleaseOutcome.released),
      builder: (BuildContext context, ReleaseState state) {
        final ReleaseBloc bloc = context.read<ReleaseBloc>();

        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const Retried()),
          child: Padding(
            // Klaviatura maydonni yopib qo'ymasligi uchun: oyna faqat
            // `isScrollControlled` bilan ochilgan, balandlikni o'zi
            // moslamaydi.
            padding: EdgeInsets.only(
              left: ScreenSize.h16,
              right: ScreenSize.h16,
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    ReleaseText.title,
                    textAlign: TextAlign.center,
                    style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
                  ),

                  Gap(ScreenSize.h16),
                  _body(state, bloc),
                  Gap(ScreenSize.h12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(ReleaseState state, ReleaseBloc bloc) {
    if (state.isChecking && state.requirements == null) return _checking();
    if (state.requirements == null) return _blocked(state, bloc, isUnknown: true);
    if (!state.isReady) return _blocked(state, bloc, isUnknown: false);

    return _form(state, bloc);
  }

  Widget _checking() => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h32),
    child: Column(
      children: <Widget>[
        CircularProgressIndicator(color: AppTheme.colors.primary),

        Gap(ScreenSize.h14),
        Text(ReleaseText.checking, style: AppTheme.data.textTheme.bodyMedium),
      ],
    ),
  );

  /// Chiqim ochilmagan holat. Sabab ikkita: talab bajarilmagan yoki talab
  /// umuman o'qilmagan — ikkalasida ham nima qilish kerakligi aytiladi (5.8).
  Widget _blocked(ReleaseState state, ReleaseBloc bloc, {required bool isUnknown}) => Column(
    children: <Widget>[
      Container(
        padding: EdgeInsets.all(ScreenSize.h16),
        decoration: BoxDecoration(
          color: AppTheme.colors.yellow.withValues(alpha: .12),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          AppIcons.warning,
          height: ScreenSize.h26,
          colorFilter: ColorFilter.mode(AppTheme.colors.yellow, BlendMode.srcIn),
        ),
      ),

      Gap(ScreenSize.h14),
      Text(
        isUnknown ? ReleaseText.unknownTitle : ReleaseText.blockedTitle,
        textAlign: TextAlign.center,
        style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.blackSoft),
      ),

      Gap(ScreenSize.h8),
      Text(
        isUnknown ? ReleaseText.unknownMessage : ReleaseText.blockedMessage(state.pendingDevices),
        textAlign: TextAlign.center,
        style: AppTheme.data.textTheme.titleSmall,
      ),

      Gap(ScreenSize.h20),
      MainButton(
        text: isUnknown ? ReleaseText.unknownAction : ReleaseText.blockedAction,
        showLoading: state.isChecking,
        onPressed: () {
          if (isUnknown) {
            bloc.add(const ReleaseStarted());
            return;
          }

          // Oyna yopiladi va chaqiruvchi talablar oynasini ochadi; qaytilgach
          // chiqim oynasi qaytadan ochilib, talab qaytadan tekshiriladi.
          context.pop(ReleaseOutcome.requirementsNeeded);
        },
      ),
    ],
  );

  Widget _form(ReleaseState state, ReleaseBloc bloc) {
    final DateTime? sentAt = state.contract.smsSentAt;
    final DateTime? expiresAt = sentAt?.add(_smsWindow);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ProductPhotoField(
          photo: state.draft.photo,
          errorText: ReleaseText.photo(state.issue) ?? ReleaseText.camera(state.camera),
          onTap: () => _takePhoto(bloc),
        ),

        Gap(ScreenSize.h16),
        _divider(),

        Gap(ScreenSize.h16),
        Text(
          ReleaseText.sentTo(PhoneFormatter.mask(state.contract.phone)),
          textAlign: TextAlign.center,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h12),
        TextInputWidget(
          hint: ReleaseText.codeHint,
          controller: _code,
          errorText: ReleaseText.code(state.issue),
          enabled: !state.isSubmitting,
          keyboardType: TextInputType.text,
          formatters: <TextInputFormatter>[LengthLimitingTextInputFormatter(ReleaseDraft.codeLength)],
          onChanged: (String value) => bloc.add(CodeChanged(value)),
        ),

        Gap(ScreenSize.h12),
        _timer(expiresAt),

        Gap(ScreenSize.h16),
        MainButton(
          text: ReleaseText.submit,
          showLoading: state.isSubmitting,
          onPressed: () => bloc.add(const ReleaseSubmitted()),
        ),
      ],
    );
  }

  /// Hisoblagich faqat xabar beradi — u tugmani to'smaydi. Server vaqti bilan
  /// qurilma vaqti farq qilishi mumkin va shu farq tufayli hali kelgan kodni
  /// kiritib bo'lmay qolishi kerak emas.
  Widget _timer(DateTime? expiresAt) {
    if (expiresAt == null || _isExpired || !expiresAt.isAfter(DateTime.now())) {
      return Text(
        ReleaseText.expired,
        textAlign: TextAlign.center,
        style: AppTheme.data.textTheme.bodySmall,
      );
    }

    return Column(
      children: <Widget>[
        SmsCountdown(expiresAt: expiresAt, onExpired: () => setState(() => _isExpired = true)),

        Gap(ScreenSize.h4),
        Text(ReleaseText.waiting, textAlign: TextAlign.center, style: AppTheme.data.textTheme.bodySmall),
      ],
    );
  }

  Widget _divider() => Row(
    children: <Widget>[
      Expanded(child: Divider(color: AppTheme.colors.stroke, height: ScreenSize.h1)),

      Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10),
        child: Text(ReleaseText.divider, style: AppTheme.data.textTheme.bodySmall),
      ),

      Expanded(child: Divider(color: AppTheme.colors.stroke, height: ScreenSize.h1)),
    ],
  );
}
