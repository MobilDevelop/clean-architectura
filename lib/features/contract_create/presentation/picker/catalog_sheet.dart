import 'package:colloborator_v3/core/result/paged.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/paged_pick_sheet.dart';
import 'package:colloborator_v3/core/widgets/sheets/sheet_surface.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/catalog_query.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/catalog/catalog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Ma'lumotnomadan bitta element tanlash oynasi.
///
/// Yuklashni [load] bajaradi, ko'rsatishni `PagedPickList`. Oyna ochilishida
/// birinchi sahifa darhol so'raladi — flex'da u faqat klaviaturadagi qidiruv
/// tugmasi bosilganda kelardi va ro'yxat bo'sh ochilardi.
Future<void> showCatalogSheet<T>({
  required BuildContext context,
  required String title,
  required String hint,
  required Future<Result<Paged<T>>> Function(CatalogQuery) load,
  required String Function(T) labelOf,
  required ValueChanged<T> onPicked,
  String Function(T)? subtitleOf,
  bool Function(T)? isSelected,
}) => showAppSheet(
  context: context,
  child: BlocProvider<CatalogBloc<T>>(
    create: (BuildContext context) =>
        CatalogBloc<T>(load: load)..add(const CatalogSearched('', debounce: false)),
    child: _CatalogSheet<T>(
      title: title,
      hint: hint,
      labelOf: labelOf,
      onPicked: onPicked,
      subtitleOf: subtitleOf,
      isSelected: isSelected,
    ),
  ),
);

final class _CatalogSheet<T> extends StatelessWidget {
  const _CatalogSheet({
    required this.title,
    required this.hint,
    required this.labelOf,
    required this.onPicked,
    this.subtitleOf,
    this.isSelected,
  });

  final String title;
  final String hint;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;
  final String Function(T)? subtitleOf;
  final bool Function(T)? isSelected;

  @override
  Widget build(BuildContext context) {
    final CatalogBloc<T> bloc = context.read<CatalogBloc<T>>();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .75,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            Expanded(
              child: BlocBuilder<CatalogBloc<T>, CatalogState<T>>(
                builder: (BuildContext context, CatalogState<T> state) => PagedPickList<T>(
                  hint: hint,
                  items: state.items,
                  isLoading: state.isLoading,
                  isLast: state.isLast,
                  failure: state.failure,
                  labelOf: labelOf,
                  subtitleOf: subtitleOf,
                  isSelected: isSelected,
                  onSearch: (String value) => bloc.add(CatalogSearched(value)),
                  onLoadMore: () => bloc.add(const CatalogNextPage()),
                  onRetry: () => bloc.add(CatalogSearched(state.search, debounce: false)),
                  onPicked: (T item) {
                    Navigator.of(context).pop();
                    onPicked(item);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
