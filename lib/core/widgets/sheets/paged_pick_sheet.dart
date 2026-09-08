import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_text.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Serverda qidiriladigan, sahifalanadigan tanlash ro'yxati.
///
/// Faqat ko'rsatadi: ma'lumotni kim va qanday yuklashini bilmaydi (6.7).
/// Qidiruvni kechiktirish ham, sahifani so'rash ham tashqarida hal qilinadi.
final class PagedPickList<T> extends StatefulWidget {
  const PagedPickList({
    super.key,
    required this.hint,
    required this.items,
    required this.isLoading,
    required this.isLast,
    required this.labelOf,
    required this.onSearch,
    required this.onLoadMore,
    required this.onPicked,
    required this.onRetry,
    this.failure,
    this.subtitleOf,
    this.isSelected,
  });

  final String hint;
  final List<T> items;
  final bool isLoading;
  final bool isLast;
  final Failure? failure;

  final String Function(T) labelOf;
  final String Function(T)? subtitleOf;
  final bool Function(T)? isSelected;

  final ValueChanged<String> onSearch;
  final VoidCallback onLoadMore;
  final ValueChanged<T> onPicked;
  final VoidCallback onRetry;

  @override
  State<PagedPickList<T>> createState() => _PagedPickListState<T>();
}

final class _PagedPickListState<T> extends State<PagedPickList<T>> {
  late final TextEditingController _search;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _scroll = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.isLoading || widget.isLast || !_scroll.hasClients) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - ScreenSize.h200) return;

    widget.onLoadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextInputWidget(
          controller: _search,
          hint: widget.hint,
          backColor: AppTheme.colors.white,
          onChanged: widget.onSearch,
        ),

        Gap(ScreenSize.h12),
        Expanded(child: _body()),
      ],
    );
  }

  Widget _body() {
    final Failure? failure = widget.failure;

    // Xato butun ro'yxatni almashtirmaydi: yuklangan sahifalar joyida qoladi.
    if (failure != null && widget.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              FailureText.of(failure),
              textAlign: TextAlign.center,
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            SizedBox(width: ScreenSize.h160, child: MainButton(text: "Qayta urinish", onPressed: widget.onRetry)),
          ],
        ),
      );
    }

    if (widget.items.isEmpty && widget.isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));
    }

    if (widget.items.isEmpty) {
      return EmptyPlaceholder(
        icon: AppIcons.search,
        title: _search.text.isEmpty ? "Ro'yxat bo'sh" : "Topilmadi",
        message: _search.text.isEmpty ? "Ma'lumot yo'q" : "Boshqa so'z bilan qidiring",
      );
    }

    final bool hasFooter = widget.isLoading || failure != null;

    return ListView.separated(
      controller: _scroll,
      padding: EdgeInsets.only(bottom: ScreenSize.h12),
      itemCount: widget.items.length + (hasFooter ? 1 : 0),
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1, color: AppSurface.line(alpha: .5)),
      itemBuilder: (BuildContext context, int index) =>
          index < widget.items.length ? _row(widget.items[index]) : _footer(failure),
    );
  }

  /// Ro'yxat oxiridagi qator: yuklanish yoki qayta urinish.
  Widget _footer(Failure? failure) => Padding(
    padding: EdgeInsets.symmetric(vertical: ScreenSize.h12),
    child: Center(
      child: failure == null
          ? SizedBox(
              height: ScreenSize.h20,
              width: ScreenSize.h20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
            )
          : TextButton(
              onPressed: widget.onLoadMore,
              child: Text(
                "Qayta urinish",
                style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.primary),
              ),
            ),
    ),
  );

  Widget _row(T item) {
    final bool selected = widget.isSelected?.call(item) ?? false;
    final String? subtitle = widget.subtitleOf?.call(item);

    return InkWell(
      onTap: () => widget.onPicked(item),
      child: Container(
        color: selected ? AppTheme.colors.primary.withValues(alpha: .06) : Colors.transparent,
        padding: EdgeInsets.symmetric(vertical: ScreenSize.h12, horizontal: ScreenSize.h8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.labelOf(item),
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(
                      color: selected ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),

                  if (subtitle != null && subtitle.isNotEmpty) ...<Widget>[
                    Gap(ScreenSize.h2),
                    Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTheme.data.textTheme.bodySmall),
                  ],
                ],
              ),
            ),

            if (selected) Icon(Icons.check_rounded, color: AppTheme.colors.primary, size: ScreenSize.h18),
          ],
        ),
      ),
    );
  }
}
