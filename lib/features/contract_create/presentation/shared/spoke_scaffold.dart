import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/backgrounds/background_wash.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_view.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:flutter/material.dart';

/// Bosqich ekranlarining umumiy qobig'i.
///
/// Nega alohida: har bir bosqich ekrani xato yuzasiga ega bo'lishi shart
/// (5.8). Qobiq shuni majburiy qiladi — `failure` konstruktor parametri, ya'ni
/// uni bermasdan yangi ekran yozib bo'lmaydi.
final class SpokeScaffold extends StatelessWidget {
  const SpokeScaffold({
    super.key,
    required this.title,
    required this.failure,
    required this.failureHandled,
    required this.retryPress,
    required this.backPress,
    required this.child,
    this.isLoading = false,
    this.bottom,
  });

  final String title;

  final Failure? failure;
  final VoidCallback failureHandled;

  /// Aloqa xatosidan keyin amalni takrorlaydi.
  final VoidCallback retryPress;

  final VoidCallback backPress;

  final bool isLoading;

  /// Pastdagi birlamchi amal. Yo'q bo'lsa chizilmaydi.
  final Widget? bottom;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Widget? action = bottom;

    return FailureView(
      failure: failure,
      onHandled: failureHandled,
      onRetry: retryPress,
      bottomInset: action == null ? null : ScreenSize.h80,
      child: Scaffold(
        backgroundColor: AppTheme.colors.backcolor,
        body: Stack(
          children: <Widget>[
            const BackgroundWash(),

            Positioned.fill(
              child: Column(
                children: <Widget>[
                  PageHeader(
                    title: title,
                    topInset: MediaQuery.paddingOf(context).top,
                    backPress: backPress,
                  ),

                  Expanded(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator(color: AppTheme.colors.primary))
                        : child,
                  ),

                  if (action != null) SafeArea(top: false, child: action),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
