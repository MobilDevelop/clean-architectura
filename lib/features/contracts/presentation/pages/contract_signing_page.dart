import 'dart:async';
import 'dart:io';

import 'package:colloborator_v3/core/router/routes.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing/contract_signing_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing/contract_signing_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing/contract_signing_state.dart';
import 'package:colloborator_v3/features/contracts/presentation/pages/signature_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/signing_text.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_file_sheet.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/participant_signing_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Shartnomani imzolash.
///
/// Ishtirokchilar orasida navbat yo'q: har biri o'z yuzini tasdiqlaydi va o'zi
/// imzolaydi. Shartnoma matni esa bitta va u hamma uchun bir marta o'qiladi.
final class ContractSigningPage extends StatelessWidget {
  const ContractSigningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContractSigningBloc, ContractSigningState>(
      listenWhen: (ContractSigningState previous, ContractSigningState current) =>
          current.isFinished && !previous.isFinished,
      // Shartnoma to'liq imzolandi — bu ekranda qiladigan ish qolmadi.
      listener: (BuildContext context, ContractSigningState state) {
        unawaited(CustomAnimatedToast.showSuccess(SigningText.finished));
        context.pop(true);
      },
      builder: (BuildContext context, ContractSigningState state) {
        final ContractSigningBloc bloc = context.read<ContractSigningBloc>();

        return FailureView(
          failure: state.failure,
          onHandled: () => bloc.add(const FailureHandled()),
          onRetry: () => bloc.add(const Retried()),
          child: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: <Widget>[
                const BackgroundWash(),
                Positioned.fill(child: _content(context, state, bloc)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context, ContractSigningState state, ContractSigningBloc bloc) => Column(
    children: <Widget>[
      PageHeader(
        title: SigningText.title,
        topInset: MediaQuery.paddingOf(context).top,
        // Bir nechta imzo qo'yilgan bo'lishi mumkin: ro'yxat baribir eskirgan.
        backPress: () => context.pop(state.signing.signedCount > 0),
      ),

      Expanded(
        child: ListView(
          padding: EdgeInsets.fromLTRB(ScreenSize.h12, ScreenSize.h12, ScreenSize.h12, ScreenSize.h24),
          children: <Widget>[
            _documentCard(context, state, bloc),

            Gap(ScreenSize.h16),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    SigningText.participants,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
                  ),
                ),

                Gap(ScreenSize.w8),
                Text(
                  SigningText.progress(state.signing),
                  style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.grey),
                ),
              ],
            ),

            Gap(ScreenSize.h10),
            for (int index = 0; index < state.signing.participants.length; index++)
              _tile(context, state, bloc, index),
          ],
        ),
      ),
    ],
  );

  /// Shartnoma matni: yuklash, ochish va o'qilgani.
  Widget _documentCard(BuildContext context, ContractSigningState state, ContractSigningBloc bloc) => Container(
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r20),
      border: Border.all(color: AppTheme.colors.grey1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          SigningText.documentTitle,
          style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
        ),

        Gap(ScreenSize.h6),
        Text(
          state.isRead ? SigningText.documentRead : SigningText.documentUnread,
          style: AppTheme.data.textTheme.bodySmall?.copyWith(
            color: state.isRead ? AppTheme.colors.primary : AppTheme.colors.grey,
          ),
        ),

        Gap(ScreenSize.h12),
        MainButton(
          text: state.hasFile ? SigningText.openDocument : SigningText.documentFailed,
          showLoading: state.isFileLoading,
          color: state.hasFile ? null : AppTheme.colors.grey,
          onPressed: () => state.hasFile
              ? unawaited(_openDocument(context, state, bloc))
              : bloc.add(const ContractFileRequested()),
        ),
      ],
    ),
  );

  Future<void> _openDocument(BuildContext context, ContractSigningState state, ContractSigningBloc bloc) =>
      showContractFileSheet(
        context: context,
        html: state.contractFile,
        isRead: state.isRead,
        onRead: () => bloc.add(const ContractRead()),
      );

  Widget _tile(BuildContext context, ContractSigningState state, ContractSigningBloc bloc, int index) {
    final SigningParticipant participant = state.signing.participants[index];

    return ParticipantSigningTile(
      participant: participant,
      role: participant.isClient ? SigningText.client : SigningText.guarantor(index),
      isExpanded: state.expandedId == participant.id,
      isBusy: state.busyParticipantId == participant.id,
      canSign: state.canSign(participant),
      canConfirmFace: state.canConfirmFace(participant),
      // Sabab faqat yuz qadamiga tegishli: imzolash matnni qayta o'qishni
      // talab qilmaydi.
      reason: state.isRead ? '' : SigningText.documentUnread,
      onToggle: () => bloc.add(ParticipantToggled(participant.id)),
      onFaceCheck: () => unawaited(_captureFace(context, bloc, participant.id)),
      onSign: () => unawaited(_openSignature(context, bloc, participant)),
      onBlocked: () => unawaited(CustomAnimatedToast.showInfo(SigningText.documentUnread)),
    );
  }

  /// Imzo alohida ekranda chiziladi.
  ///
  /// Nega bu yerda: chizish maydoni scroll qiladigan ro'yxat ichida turmasligi
  /// kerak — vertikal harakat uchun ikkita da'vogar bo'lib, bazida chizish
  /// o'rniga ro'yxat surilardi.
  Future<void> _openSignature(
    BuildContext context,
    ContractSigningBloc bloc,
    SigningParticipant participant,
  ) async {
    final SignatureDraw? draw = await context.push<SignatureDraw>(
      Routes.signature.path,
      extra: participant.name,
    );

    if (draw == null) return;

    bloc.add(
      SignatureSubmitted(
        participantId: participant.id,
        signature: draw.signature,
        comment: draw.comment,
      ),
    );
  }

  /// Kamerani sahifa ochadi, bloc faqat `File` ni oladi (6.2).
  ///
  /// Kamera sahifasi mijozlar featurei ichida, lekin u marshrut orqali
  /// chaqiriladi va natijasi oddiy `File` — shuning uchun bu feature uni
  /// import qilmaydi (1.3).
  Future<void> _captureFace(BuildContext context, ContractSigningBloc bloc, int participantId) async {
    final File? photo = await context.push<File>(Routes.faceCamera.path);
    if (photo == null) return;

    bloc.add(FaceCaptured(participantId: participantId, photo: photo));
  }
}
