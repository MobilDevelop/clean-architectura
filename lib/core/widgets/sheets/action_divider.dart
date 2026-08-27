import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Amallar orasidagi ingichka chiziq — ikonka kengligicha ichkariga surilgan.
final class ActionDivider extends StatelessWidget {
  const ActionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: ScreenSize.h60, right: ScreenSize.h6),
      child: ColoredBox(color: AppSurface.line(alpha: .6), child: const SizedBox(height: 1, width: double.infinity)),
    );
  }
}
