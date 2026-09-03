import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_form.dart';
import 'package:colloborator_v3/features/customers/presentation/styles/customer_form_issue_text.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/select_tile.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Manzil: viloyat → tuman → mahalla, so'ng ko'cha va uy raqami.
final class AddressSection extends StatelessWidget {
  const AddressSection({
    super.key,
    required this.form,
    required this.issue,
    required this.streetController,
    required this.houseController,
    required this.pickProvince,
    required this.pickRegion,
    required this.pickVillage,
    required this.onStreetChanged,
    required this.onHouseChanged,
  });

  final CustomerForm form;
  final CustomerFormIssue issue;
  final TextEditingController streetController;
  final TextEditingController houseController;
  final VoidCallback pickProvince;
  final VoidCallback pickRegion;
  final VoidCallback pickVillage;
  final ValueChanged<String> onStreetChanged;
  final ValueChanged<String> onHouseChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SelectTile(
          title: "Viloyat",
          hint: "Tanlang",
          value: form.province?.title ?? '',
          errorText: CustomerFormIssueText.province(issue),
          onTap: pickProvince,
        ),

        Gap(ScreenSize.h14),
        SelectTile(
          title: "Tuman",
          hint: form.province == null ? "Avval viloyatni tanlang" : "Tanlang",
          value: form.region?.title ?? '',
          errorText: CustomerFormIssueText.region(issue),
          enabled: form.province != null,
          onTap: pickRegion,
        ),

        Gap(ScreenSize.h14),
        SelectTile(
          title: "Mahalla",
          hint: form.region == null ? "Avval tumanni tanlang" : "Tanlang",
          value: form.village?.title ?? '',
          errorText: CustomerFormIssueText.village(issue),
          enabled: form.region != null,
          onTap: pickVillage,
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          controller: streetController,
          title: "Ko'cha",
          hint: "Ko'cha nomi",
          errorText: CustomerFormIssueText.street(issue),
          onChanged: onStreetChanged,
        ),

        Gap(ScreenSize.h14),
        TextInputWidget(
          controller: houseController,
          title: "Uy raqami",
          hint: "12A",
          errorText: CustomerFormIssueText.house(issue),
          onChanged: onHouseChanged,
        ),
      ],
    );
  }
}
