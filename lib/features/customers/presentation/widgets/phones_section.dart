import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/customer_form_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/select_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Uchta raqam: shaxsiy, qarindosh (kimligi bilan) va tanish.
final class PhonesSection extends StatelessWidget {
  const PhonesSection({
    super.key,
    required this.form,
    required this.issue,
    required this.mainController,
    required this.relativeController,
    required this.friendController,
    required this.onMainChanged,
    required this.onRelativeChanged,
    required this.onFriendChanged,
    required this.pickRelativeKind,
  });

  final CustomerForm form;
  final CustomerFormIssue issue;
  final TextEditingController mainController;
  final TextEditingController relativeController;
  final TextEditingController friendController;
  final ValueChanged<String> onMainChanged;
  final ValueChanged<String> onRelativeChanged;
  final ValueChanged<String> onFriendChanged;
  final VoidCallback pickRelativeKind;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextInputWidget(
          controller: mainController,
          title: "Shaxsiy raqam",
          hint: "+998",
          keyboardType: TextInputType.number,
          errorText: CustomerFormIssueText.mainPhone(issue),
          formatters: <TextInputFormatter>[PhoneFormatter()],
          onChanged: onMainChanged,
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          controller: relativeController,
          title: "Qarindosh raqami",
          hint: "+998",
          keyboardType: TextInputType.number,
          errorText: CustomerFormIssueText.relativePhone(issue),
          formatters: <TextInputFormatter>[PhoneFormatter()],
          onChanged: onRelativeChanged,
        ),

        Gap(ScreenSize.h14),
        SelectTile(
          title: "Kim bo'ladi",
          hint: "Tanlang",
          value: form.relativeKind?.title ?? '',
          errorText: CustomerFormIssueText.relativeKind(issue),
          onTap: pickRelativeKind,
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          controller: friendController,
          title: "Tanish raqami",
          hint: "+998",
          keyboardType: TextInputType.number,
          errorText: CustomerFormIssueText.friendPhone(issue),
          formatters: <TextInputFormatter>[PhoneFormatter()],
          onChanged: onFriendChanged,
        ),
      ],
    );
  }
}
