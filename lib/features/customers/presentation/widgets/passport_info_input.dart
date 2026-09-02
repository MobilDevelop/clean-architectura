import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/birth_date_formatter.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/passport_number_formatter.dart';
import 'package:colloborator_v3/features/customers/presentation/formatters/passport_series_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

/// Seriya va raqam alohida maydon: bitta maydonda klaviatura turini almashtirib
/// bo'lmaydi — Flutter uni faqat fokus o'rnatilganda tizimga yuboradi.
final class PassportInfoInput extends StatelessWidget {
  const PassportInfoInput({
    super.key,
    required this.seriesController,
    required this.numberController,
    required this.birthdayController,
    required this.numberFocus,
    required this.seriesError,
    required this.numberError,
    required this.birthdayError,
    required this.onSeriesChanged,
    required this.onNumberChanged,
    required this.onBirthdayChanged,
    required this.pickDate,
  });

  final TextEditingController seriesController;
  final TextEditingController numberController;
  final TextEditingController birthdayController;

  /// Seriya to'lgach fokus shu maydonga o'tadi.
  final FocusNode numberFocus;

  final String? seriesError;
  final String? numberError;
  final String? birthdayError;

  final ValueChanged<String> onSeriesChanged;
  final ValueChanged<String> onNumberChanged;
  final ValueChanged<String> onBirthdayChanged;
  final VoidCallback pickDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: ScreenSize.w96,
              child: TextInputWidget(
                controller: seriesController,
                title: "Seriya",
                hint: "AA",
                errorText: seriesError,
                keyboardType: TextInputType.text,
                formatters: <TextInputFormatter>[PassportSeriesFormatter()],
                onChanged: onSeriesChanged,
              ),
            ),

            Gap(ScreenSize.w10),
            Expanded(
              child: TextInputWidget(
                controller: numberController,
                focusNode: numberFocus,
                title: "Pasport raqami",
                hint: "1234567",
                errorText: numberError,
                keyboardType: TextInputType.number,
                formatters: <TextInputFormatter>[PassportNumberFormatter()],
                onChanged: onNumberChanged,
              ),
            ),
          ],
        ),

        Gap(ScreenSize.h16),
        TextInputWidget(
          controller: birthdayController,
          title: "Tug'ilgan sana",
          hint: "kun.oy.yil",
          errorText: birthdayError,
          keyboardType: TextInputType.number,
          formatters: <TextInputFormatter>[BirthDateFormatter()],
          suffixIcon: AppIcons.calendar,
          suffixPress: pickDate,
          onChanged: onBirthdayChanged,
        ),
      ],
    );
  }
}
