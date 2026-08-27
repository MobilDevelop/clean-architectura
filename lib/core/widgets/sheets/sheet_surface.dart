import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Pastdan chiqadigan oynani ochadi.
///
/// Nega alohida: oynaning ramkasi — burchak radiusi, foni, tutqichi va pastki
/// xavfsiz maydoni — barcha oynalarda bir xil bo'lishi kerak.
Future<void> showAppSheet({required BuildContext context, required Widget child}) => showModalBottomSheet<void>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  backgroundColor: AppTheme.colors.white,
  barrierColor: AppTheme.colors.black.withValues(alpha: .35),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(ScreenSize.r30))),
  builder: (BuildContext context) => SheetSurface(child: child),
);

/// Oynaning ramkasi: tutqich va pastki xavfsiz maydon.
final class SheetSurface extends StatelessWidget {
  const SheetSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: ScreenSize.h8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: ScreenSize.h4,
              width: ScreenSize.h44,
              margin: EdgeInsets.only(top: ScreenSize.h10, bottom: ScreenSize.h14),
              decoration: BoxDecoration(
                color: AppTheme.colors.grey1,
                borderRadius: BorderRadius.circular(ScreenSize.r8),
              ),
            ),

            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
