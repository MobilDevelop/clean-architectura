import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Ro'yxatdan bitta element tanlash oynasi.
///
/// Qidiruv ro'yxat uzun bo'lganda chiqadi — 14 ta viloyat uchun u ortiqcha,
/// 500 ta mahalla uchun esa shartsiz kerak.
Future<void> showPickSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) labelOf,
  required ValueChanged<T> onPicked,
  T? selected,
  bool isLoading = false,
  int searchAfter = 12,
}) => showAppSheet(
  context: context,
  child: PickSheet<T>(
    title: title,
    items: items,
    labelOf: labelOf,
    onPicked: onPicked,
    selected: selected,
    isLoading: isLoading,
    searchAfter: searchAfter,
  ),
);

final class PickSheet<T> extends StatefulWidget {
  const PickSheet({
    super.key,
    required this.title,
    required this.items,
    required this.labelOf,
    required this.onPicked,
    required this.isLoading,
    required this.searchAfter,
    this.selected,
  });

  final String title;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  /// Hozir tanlangan element — ro'yxatda ajratib ko'rsatiladi.
  final T? selected;

  /// Ro'yxat hali kelmagan — bo'sh ro'yxat "topilmadi" degani emas.
  final bool isLoading;

  final int searchAfter;

  @override
  State<PickSheet<T>> createState() => _PickSheetState<T>();
}

final class _PickSheetState<T> extends State<PickSheet<T>> {
  late final TextEditingController _search;
  final GlobalKey _selectedKey = GlobalKey();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();

    // Uzun ro'yxatda tanlangani ekran tashqarisida qolmasin.
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSelected());
  }

  void _showSelected() {
    final BuildContext? target = _selectedKey.currentContext;
    if (target == null) return;

    unawaited(Scrollable.ensureVisible(target, alignment: .3, duration: const Duration(milliseconds: 250)));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<T> get _visible {
    if (_query.isEmpty) return widget.items;

    final String query = _query.toLowerCase();

    return widget.items.where((T item) => widget.labelOf(item).toLowerCase().contains(query)).toList();
  }

  Widget _row(T item) {
    final bool isSelected = widget.selected != null && item == widget.selected;

    return InkWell(
      key: isSelected ? _selectedKey : null,
      onTap: () {
        Navigator.of(context).pop();
        widget.onPicked(item);
      },
      child: Container(
        color: isSelected ? AppTheme.colors.primary.withValues(alpha: .06) : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: ScreenSize.h14, horizontal: ScreenSize.h8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.labelOf(item),
                style: AppTheme.data.textTheme.titleSmall?.copyWith(
                  color: isSelected ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),

            if (isSelected) Icon(Icons.check_rounded, color: AppTheme.colors.primary, size: ScreenSize.h18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<T> items = _visible;
    final bool hasSearch = widget.items.length > widget.searchAfter;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            if (hasSearch) ...<Widget>[
              Gap(ScreenSize.h12),
              TextInputWidget(
                controller: _search,
                hint: "Qidirish",
                backColor: AppTheme.colors.white,
                onChanged: (String value) => setState(() => _query = value),
              ),
            ],

            Gap(ScreenSize.h12),
            Expanded(
              child: widget.isLoading && widget.items.isEmpty
                  ? Center(child: CircularProgressIndicator(color: AppTheme.colors.primary))
                  : items.isEmpty
                  ? EmptyPlaceholder(
                      icon: AppIcons.search,
                      title: _query.isEmpty ? "Ro'yxat bo'sh" : "Topilmadi",
                      message: _query.isEmpty ? "Ma'lumot yuklanmadi, qayta urinib ko'ring" : "Boshqa so'z bilan qidiring",
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(bottom: ScreenSize.h12),
                      itemCount: items.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(height: 1, color: AppSurface.line(alpha: .5)),
                      itemBuilder: (BuildContext context, int index) => _row(items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
