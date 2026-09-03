import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';

/// Flex shartnomasi bo'yicha serverdan kelgan xabarlar.
final class FlexMessagesCard extends StatelessWidget {
  const FlexMessagesCard({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: "Shartnoma bo'yicha xabarlar",
      icon: AppIcons.warning,
      color: AppTheme.colors.yellow,
      child: Column(
        children: messages
            .map(
              (String message) => Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: ScreenSize.h8),
                padding: EdgeInsets.all(ScreenSize.h10),
                decoration: BoxDecoration(
                  color: AppTheme.colors.yellow.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(ScreenSize.r10),
                ),
                child: Text(
                  message,
                  style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
