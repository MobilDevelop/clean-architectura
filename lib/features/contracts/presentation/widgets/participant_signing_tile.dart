import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/signing_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Bitta ishtirokchi: ma'lumoti, yuz tasdig'i va imzo tugmasi.
///
/// Widget qaror qabul qilmaydi (6.7): nima ochiq, nima mumkinligini sahifa
/// aytadi, bu yerda faqat ko'rsatiladi.
final class ParticipantSigningTile extends StatelessWidget {
  const ParticipantSigningTile({
    super.key,
    required this.participant,
    required this.role,
    required this.isExpanded,
    required this.isBusy,
    required this.canSign,
    required this.canConfirmFace,
    required this.reason,
    required this.onToggle,
    required this.onFaceCheck,
    required this.onSign,
    required this.onBlocked,
  });

  final SigningParticipant participant;
  final String role;
  final bool isExpanded;

  /// Shu ishtirokchi uchun yozuv ketyapti.
  final bool isBusy;

  final bool canSign;

  /// Yuzni tasdiqlash uchun shartnoma matni o'qilganmi.
  final bool canConfirmFace;

  /// Imzolash mumkin bo'lmasa — sababi. Bo'sh satr — sabab yo'q.
  final String reason;

  final VoidCallback onToggle;
  final VoidCallback onFaceCheck;

  /// Imzo ekranini ochadi.
  final VoidCallback onSign;

  /// Imzolash mumkin bo'lmaganda bosildi — sabab ko'rsatiladi.
  final VoidCallback onBlocked;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.h12),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(ScreenSize.r20),
            child: Padding(padding: EdgeInsets.all(ScreenSize.h14), child: _header(participant)),
          ),

          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(ScreenSize.h14, 0, ScreenSize.h14, ScreenSize.h14),
              child: _body(participant),
            ),
        ],
      ),
    );
  }

  Widget _header(SigningParticipant participant) => Row(
    children: <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
            ),

            Gap(ScreenSize.h2),
            Text(
              participant.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.black),
            ),

            Gap(ScreenSize.h4),
            Text(
              participant.passport,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.bodyMedium,
            ),
          ],
        ),
      ),

      Gap(ScreenSize.w8),
      _badge(participant),
    ],
  );

  Widget _badge(SigningParticipant participant) {
    final bool isSigned = participant.isSigned;
    final Color color = isSigned
        ? AppTheme.colors.primary
        : participant.isFaceChecked
        ? AppTheme.colors.blue
        : AppTheme.colors.grey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(ScreenSize.r12),
        border: Border.all(color: color.withValues(alpha: .4)),
      ),
      child: Text(
        isSigned
            ? SigningText.signed
            : participant.isFaceChecked
            ? SigningText.faceChecked
            : SigningText.faceCheck,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.data.textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }

  Widget _body(SigningParticipant participant) {
    // Imzolangan ishtirokchida qo'shimcha hech nima ochilmaydi: qo'yilgan
    // imzoni almashtirish yo'li yo'q va ochiq maydon buni va'da qilib qo'yardi.
    if (participant.isSigned) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          SigningText.signed,
          style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.primary),
        ),
      );
    }

    if (!participant.isFaceChecked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(SigningText.faceNeeded, style: AppTheme.data.textTheme.bodyMedium),

          Gap(ScreenSize.h10),
          MainButton(
            text: SigningText.faceCheck,
            // Tugma o'chirilmaydi: matn o'qilmagan bo'lsa sababi tagida (5.8).
            color: canConfirmFace ? null : AppTheme.colors.grey,
            showLoading: isBusy,
            onPressed: canConfirmFace ? onFaceCheck : onBlocked,
          ),

          if (reason.isNotEmpty) ...<Widget>[
            Gap(ScreenSize.h6),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
            ),
          ],
        ],
      );
    }

    // Chizish maydoni bu yerda emas, alohida ekranda: ro'yxat ichida vertikal
    // harakat uchun ikkita da'vogar bo'lib, bazida chizish o'rniga ro'yxat
    // surilardi.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        MainButton(
          text: SigningText.openSignature,
          // Tugma o'chirilmaydi: nima yetishmayotgani tagida yoziladi (5.8).
          color: canSign ? null : AppTheme.colors.grey,
          showLoading: isBusy,
          onPressed: canSign ? onSign : onBlocked,
        ),
      ],
    );
  }
}
