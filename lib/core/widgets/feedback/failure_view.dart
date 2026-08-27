import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/core/widgets/feedback/connection_banner.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Ichki nosozlikda foydalanuvchiga ko'rsatiladigan matn.
///
/// Nega `failure.message` emas: bu guruhdagi xatolarni foydalanuvchi tuzata
/// olmaydi va texnik matn ("Server javobi kutilgan shaklda emas") unga hech
/// nima bermaydi. Tafsilot botga ketadi (5.7).
const String _internalMessage = "Xatolik yuz berdi. Birozdan keyin qayta urinib ko'ring";

/// Xatoni guruhiga qarab ko'rsatadi (5.6).
///
/// Sahifa faqat `failure` ni beradi — nima ko'rsatilishini shu widget hal
/// qiladi. Shuning uchun barcha ekranlarda xato bir xil xatti-harakat qiladi.
final class FailureView extends StatefulWidget {
  const FailureView({
    super.key,
    required this.failure,
    required this.onHandled,
    required this.child,
    this.onRetry,
    this.bottomInset,
  });

  final Failure? failure;

  /// Xato ko'rsatildi — state'dan tozalash uchun.
  final VoidCallback onHandled;

  /// Aloqa xatosidan keyin amalni takrorlash. `null` bo'lsa tugma chiqmaydi.
  final VoidCallback? onRetry;

  /// Banner pastdan qancha yuqorida tursin (FAB yoki menyu ustida).
  final double? bottomInset;

  final Widget child;

  @override
  State<FailureView> createState() => _FailureViewState();
}

final class _FailureViewState extends State<FailureView> {
  @override
  void didUpdateWidget(covariant FailureView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final Failure? failure = widget.failure;
    if (failure == null || failure == oldWidget.failure) return;

    // Nega kadrdan keyin: bu yerda `emit` yoki dialog chaqirilsa, u qurilish
    // paytiga to'g'ri keladi va Flutter xato beradi.
    WidgetsBinding.instance.addPostFrameCallback((_) => _handle(failure));
  }

  void _handle(Failure failure) {
    if (!mounted) return;

    switch (failure.group) {
      // Banner qurilishda ko'rinadi — bir martalik ta'sir kerak emas.
      case FailureGroup.connection:
        return;

      case FailureGroup.session:
        unawaited(_showSessionExpired());

      case FailureGroup.input:
        unawaited(CustomAnimatedToast.showInfo(failure.message));
        widget.onHandled();

      case FailureGroup.internal:
        unawaited(CustomAnimatedToast.showInfo(_internalMessage));
        widget.onHandled();
    }
  }

  /// Sessiya tugadi: foydalanuvchi ishini davom ettira olmaydi, shuning uchun
  /// toast emas, to'xtatadigan dialog. Yopilgach chiqib ketiladi va router
  /// o'zi login sahifasiga olib boradi.
  Future<void> _showSessionExpired() async {
    final AuthNotifier auth = context.read<AuthNotifier>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: AppIcons.logout,
        accent: AppTheme.colors.red,
        title: "Sessiya tugadi",
        message: "Xavfsizlik uchun tizimdan chiqildi. Davom etish uchun qaytadan kiring",
        actionLabel: "Kirish",
        onAction: () => Navigator.of(dialogContext).pop(),
      ),
    );

    if (!mounted) return;

    widget.onHandled();
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final Failure? failure = widget.failure;
    final bool showBanner = failure != null && failure.group == FailureGroup.connection;

    return Stack(
      children: <Widget>[
        widget.child,

        if (showBanner)
          Positioned(
            left: ScreenSize.h12,
            right: ScreenSize.h12,
            bottom: (widget.bottomInset ?? 0) + ScreenSize.h12,
            child: ConnectionBanner(
              message: failure.message,
              onRetry: widget.onRetry,
              onClose: widget.onHandled,
            ),
          ),
      ],
    );
  }
}
