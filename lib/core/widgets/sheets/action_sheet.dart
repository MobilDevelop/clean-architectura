import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Amallar oynasini ochadi.
///
/// Komponent featurega xos hech nima bilmaydi: sarlavhani ham, amallar
/// ro'yxatini ham tashqaridan oladi.
Future<void> showActionSheet({
  required BuildContext context,
  required Widget header,
  required List<Widget> actions,
}) => showAppSheet(
  context: context,
  child: ActionSheet(header: header, actions: actions),
);

/// Sarlavha va amallar ro'yxati.
final class ActionSheet extends StatelessWidget {
  const ActionSheet({super.key, required this.header, required this.actions});

  final Widget header;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
          child: header,
        ),

        Gap(ScreenSize.h14),
        ColoredBox(color: AppSurface.line(), child: const SizedBox(height: 1, width: double.infinity)),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
          child: Column(mainAxisSize: MainAxisSize.min, children: actions),
        ),
      ],
    );
  }
}
