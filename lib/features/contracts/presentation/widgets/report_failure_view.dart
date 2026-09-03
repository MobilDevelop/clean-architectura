import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Tab ichidagi xato. Sahifadagi `FailureView` xatoni guruhiga qarab
/// yo'naltiradi (401 da chiqarish, aloqa uzilganda banner), lekin toast o'chib
/// ketgach tab bo'sh qolmasligi kerak — sabab va qayta urinish shu yerda turadi.
final class ReportFailureView extends StatelessWidget {
  const ReportFailureView({super.key, required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              FailureText.of(failure),
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            SizedBox(width: ScreenSize.h160, child: MainButton(text: "Qayta urinish", onPressed: onRetry)),
          ],
        ),
      ),
    );
  }
}
