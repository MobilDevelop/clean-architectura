import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/border_button.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Taqvimda nechta yil orqaga qarash mumkin.
const int _yearSpan = 1;

/// Sana filtri oynasini ochadi.
Future<void> showContractsFilter({
  required BuildContext context,
  required DateTime? date,
  required DateTime today,
  required ValueChanged<DateTime> applyDate,
  required VoidCallback clearDate,
}) => showAppSheet(
  context: context,
  child: ContractsFilterSheet(date: date, today: today, applyDate: applyDate, clearDate: clearDate),
);

/// Sana bo'yicha filtr.
///
/// Tanlangan kun darhol qo'llanmaydi — foydalanuvchi "Qo'llash" ni bosmaguncha
/// oyna ichida turadi, ya'ni har bosishda so'rov ketmaydi.
final class ContractsFilterSheet extends StatefulWidget {
  const ContractsFilterSheet({
    super.key,
    required this.date,
    required this.today,
    required this.applyDate,
    required this.clearDate,
  });

  final DateTime? date;

  /// Bugungi kun tashqaridan beriladi — taqvimning yuqori chegarasi (9.4).
  final DateTime today;
  final ValueChanged<DateTime> applyDate;
  final VoidCallback clearDate;

  @override
  State<ContractsFilterSheet> createState() => _ContractsFilterSheetState();
}

final class _ContractsFilterSheetState extends State<ContractsFilterSheet> {
  late List<DateTime?> _selected;

  @override
  void initState() {
    super.initState();
    _selected = <DateTime?>[widget.date];
  }

  DateTime? get _picked => _selected.isEmpty ? null : _selected.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: ScreenSize.h42,
                width: ScreenSize.h42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(ScreenSize.r14),
                  border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .22)),
                ),
                child: SvgPicture.asset(
                  AppIcons.calendar,
                  height: ScreenSize.h20,
                  colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
                ),
              ),

              Gap(ScreenSize.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Sana bo'yicha filtr",
                      style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                    ),

                    Gap(ScreenSize.h2),
                    Text("Kunni tanlang", style: AppTheme.data.textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),

          Gap(ScreenSize.h14),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.colors.white,
              borderRadius: BorderRadius.circular(ScreenSize.r20),
              border: AppSurface.border(),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ScreenSize.r20),
              child: CalendarDatePicker2(
                value: _selected,
                onValueChanged: (List<DateTime> dates) => setState(() => _selected = <DateTime?>[...dates]),
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.single,
                  firstDate: DateTime(widget.today.year - _yearSpan, widget.today.month, widget.today.day),
                  lastDate: widget.today,
                  centerAlignModePicker: true,
                  controlsHeight: ScreenSize.h50,
                  dayBorderRadius: BorderRadius.circular(ScreenSize.r12),
                  selectedDayHighlightColor: AppTheme.colors.primary,
                  daySplashColor: AppTheme.colors.primary.withValues(alpha: .2),
                  dayTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                  selectedDayTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.white),
                  weekdayLabelTextStyle: AppTheme.data.textTheme.labelMedium?.copyWith(
                    color: AppTheme.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  controlsTextStyle: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),
            ),
          ),

          Gap(ScreenSize.h14),
          Row(
            children: <Widget>[
              Expanded(
                child: BorderButton(
                  text: "Tozalash",
                  color: AppTheme.colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.clearDate();
                  },
                ),
              ),

              Gap(ScreenSize.w10),
              Expanded(
                child: MainButton(
                  text: "Qo'llash",
                  onPressed: () {
                    final DateTime? value = _picked;
                    Navigator.of(context).pop();
                    if (value != null) widget.applyDate(value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
