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

/// Sana tanlash oynasini ochadi.
///
/// Nega `core/` da: sanani ikki joyda tanlaymiz — shartnomalar filtri va
/// tug'ilgan sana. Taqvim ko'rinishi ikkalasida bir xil bo'lishi kerak.
Future<void> showDateSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required DateTime? date,
  required DateTime firstDate,
  required DateTime lastDate,
  required ValueChanged<DateTime> onPicked,
  CalendarDatePicker2Mode viewMode = CalendarDatePicker2Mode.day,
  String confirmText = "Qo'llash",
  VoidCallback? onClear,
}) => showAppSheet(
  context: context,
  child: DateSheet(
    title: title,
    subtitle: subtitle,
    date: date,
    firstDate: firstDate,
    lastDate: lastDate,
    onPicked: onPicked,
    viewMode: viewMode,
    confirmText: confirmText,
    onClear: onClear,
  ),
);

/// Tanlangan kun darhol qo'llanmaydi — foydalanuvchi tasdiqlamaguncha oyna
/// ichida turadi.
final class DateSheet extends StatefulWidget {
  const DateSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.onPicked,
    required this.viewMode,
    required this.confirmText,
    this.onClear,
  });

  final String title;
  final String subtitle;
  final DateTime? date;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onPicked;

  /// Uzoq sanalar uchun taqvim yildan boshlanadi.
  final CalendarDatePicker2Mode viewMode;

  final String confirmText;

  /// `null` — "Tozalash" tugmasi chiqmaydi.
  final VoidCallback? onClear;

  @override
  State<DateSheet> createState() => _DateSheetState();
}

final class _DateSheetState extends State<DateSheet> {
  late List<DateTime?> _selected;

  @override
  void initState() {
    super.initState();
    _selected = <DateTime?>[widget.date];
  }

  DateTime? get _picked => _selected.isEmpty ? null : _selected.first;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? clear = widget.onClear;
    final DateTime? picked = _picked;

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
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                    ),

                    Gap(ScreenSize.h2),
                    Text(widget.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.data.textTheme.bodyMedium),
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
                  calendarViewMode: widget.viewMode,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  centerAlignModePicker: true,
                  controlsHeight: ScreenSize.h50,
                  dayBorderRadius: BorderRadius.circular(ScreenSize.r12),
                  selectedDayHighlightColor: AppTheme.colors.primary,
                  daySplashColor: AppTheme.colors.primary.withValues(alpha: .2),
                  dayTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                  selectedDayTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.white),
                  yearTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                  selectedYearTextStyle: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.white),
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
              if (clear != null) ...<Widget>[
                Expanded(
                  child: BorderButton(
                    text: "Tozalash",
                    color: AppTheme.colors.grey,
                    onPressed: () {
                      Navigator.of(context).pop();
                      clear();
                    },
                  ),
                ),

                Gap(ScreenSize.w10),
              ],

              Expanded(
                // Kun tanlanmaguncha o'chiq: aks holda oyna yopilib, hech nima
                // o'zgarmasdi va sabab aytilmasdi (5.8).
                child: MainButton(
                  text: widget.confirmText,
                  color: picked == null ? AppTheme.colors.grey : null,
                  onPressed: () {
                    if (picked == null) return;

                    Navigator.of(context).pop();
                    widget.onPicked(picked);
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
