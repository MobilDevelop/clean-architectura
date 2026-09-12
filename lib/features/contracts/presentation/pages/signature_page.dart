import 'dart:async';
import 'dart:typed_data';

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:colloborator_v3/features/contracts/presentation/styles/signing_text.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Imzo qo'yish ekrani natijasi.
typedef SignatureDraw = ({Uint8List signature, String comment});

/// Imzoni to'liq ekranda oladi.
///
/// Nega alohida ekran: chizish maydoni scroll qiladigan ota-ona ichida
/// turmasligi kerak. Ro'yxat ichida vertikal harakat uchun ikkita da'vogar
/// bo'ladi — pad va ro'yxat — va qaysi biri yutishi barmoqning tikligiga
/// bog'liq bo'lib qoladi. Bu yerda scroll umuman yo'q, ya'ni to'qnashuv
/// sozlash bilan emas, tuzilma bilan yopilgan.
///
/// Ekran serverga murojaat qilmaydi: u faqat baytlarni va izohni qaytaradi,
/// yuborishni imzolash ekranining bloci bajaradi.
final class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key, required this.participantName});

  final String participantName;

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

final class _SignaturePageState extends State<SignaturePage> {
  final GlobalKey<SignaturePadState> _pad = GlobalKey<SignaturePadState>();
  final TextEditingController _comment = TextEditingController();

  bool _isExporting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    final Uint8List? bytes = await _pad.currentState?.export();

    if (!mounted) return;
    setState(() => _isExporting = false);

    if (bytes == null) {
      await CustomAnimatedToast.showInfo(SigningText.emptySignature);
      return;
    }

    if (!mounted) return;

    context.pop<SignatureDraw>((signature: bytes, comment: _comment.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    // `resizeToAvoidBottomInset` o'chirilmaydi: izoh maydoni pastda va
    // klaviatura ochilganda uning tagida qolib ketardi. Maydon vaqtincha
    // kichrayadi, lekin chizilgani yo'qolmaydi — eksport nuqtalarning haqiqiy
    // chegarasi bo'yicha bajariladi (`SignaturePad.export`).
    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: Stack(
        children: <Widget>[
          const BackgroundWash(),

          Positioned.fill(
            child: Column(
              children: <Widget>[
                PageHeader(
                  title: SigningText.sign,
                  topInset: MediaQuery.paddingOf(context).top,
                  backPress: () => context.pop(),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h12, ScreenSize.h16, 0),
                  child: Text(
                    widget.participantName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.black),
                  ),
                ),

                // Maydon qolgan bo'sh joyni to'liq egallaydi.
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h12, ScreenSize.h16, 0),
                    child: SignaturePad(key: _pad, isLocked: _isExporting),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h10, ScreenSize.h16, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextInputWidget(hint: SigningText.commentHint, controller: _comment),
                      ),

                      Gap(ScreenSize.w8),
                      TextButton(
                        onPressed: _isExporting ? null : () => _pad.currentState?.clear(),
                        child: Text(
                          SigningText.clearSignature,
                          style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),

                SafeArea(
                  top: false,
                  child: MainButton(
                    text: SigningText.sign,
                    margin: EdgeInsets.symmetric(horizontal: ScreenSize.h16, vertical: ScreenSize.h8),
                    showLoading: _isExporting,
                    // Tugma o'chirilmaydi: imzo chizilmagan bo'lsa sababi
                    // aytiladi (5.8).
                    onPressed: () => unawaited(_submit()),
                  ),
                ),
              ],
              
            ),
          ),
        ], 
      ),
    );
  }
}
