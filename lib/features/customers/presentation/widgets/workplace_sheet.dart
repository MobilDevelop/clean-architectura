import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/feedback/failure_text.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/text_input.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/add_customer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Ish joyi qidiruvi. Ro'yxat serverda qidiriladi — u minglab yozuvdan iborat,
/// shuning uchun `PickSheet` dagi mahalliy filtr yaramaydi.
final class WorkplaceSheet extends StatefulWidget {
  const WorkplaceSheet({super.key, required this.onPicked, this.selected});

  final ValueChanged<WorkplaceInfo> onPicked;

  /// Hozir tanlangan ish joyi — ro'yxatda ajratib ko'rsatiladi.
  final WorkplaceInfo? selected;

  @override
  State<WorkplaceSheet> createState() => _WorkplaceSheetState();
}

final class _WorkplaceSheetState extends State<WorkplaceSheet> {
  late final TextEditingController _search;
  late final AddCustomerBloc _bloc;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _bloc = context.read<AddCustomerBloc>();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * .7,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: ScreenSize.h16),
        child: Column(
          children: <Widget>[
            Text(
              "Ish joyi",
              style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft),
            ),

            Gap(ScreenSize.h12),
            TextInputWidget(
              controller: _search,
              hint: "Tashkilot nomi yoki STIR",
              autoFocus: true,
              backColor: AppTheme.colors.white,
              onChanged: (String value) => _bloc.add(WorkplaceQueryChanged(value)),
            ),

            Gap(ScreenSize.h12),
            Expanded(
              // Xato ham shu yerda: sahifadagi banner modal oynaning ostida
              // qolib ketadi va foydalanuvchi uni ko'rmaydi (5.8).
              child: BlocSelector<AddCustomerBloc, AddCustomerState, ({bool isLoading, List<WorkplaceInfo> items, Failure? failure})>(
                selector: (AddCustomerState state) =>
                    (isLoading: state.isWorkplaceLoading, items: state.workplaces, failure: state.failure),
                builder: (BuildContext context, ({bool isLoading, List<WorkplaceInfo> items, Failure? failure}) data) =>
                    _list(data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(({bool isLoading, List<WorkplaceInfo> items, Failure? failure}) data) {
    if (data.isLoading) return Center(child: CircularProgressIndicator(color: AppTheme.colors.primary));

    final Failure? failure = data.failure;
    if (failure != null) {
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
            SizedBox(
              width: ScreenSize.h160,
              child: MainButton(
                text: "Qayta urinish",
                onPressed: () => _bloc.add(WorkplaceQueryChanged(_search.text)),
              ),
            ),
          ],
        ),
      );
    }

    if (data.items.isEmpty) {
      return EmptyPlaceholder(
        icon: AppIcons.workplace,
        title: _search.text.isEmpty ? "Ish joyini qidiring" : "Topilmadi",
        message: _search.text.isEmpty ? "Tashkilot nomini yozing" : "Boshqa so'z bilan qidiring",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: ScreenSize.h12),
      itemCount: data.items.length,
      separatorBuilder: (BuildContext context, int index) => Divider(height: 1, color: AppSurface.line(alpha: .5)),
      itemBuilder: (BuildContext context, int index) {
        final WorkplaceInfo workplace = data.items[index];
        // Aynan `id` bo'yicha: kategoriya mijoz obyektida va qidiruv natijasida
        // har xil shaklda kelishi mumkin, ya'ni to'liq taqqoslash mos kelmasligi mumkin.
        final bool isSelected = workplace.id == widget.selected?.id;

        return InkWell(
          onTap: () {
            Navigator.of(context).pop();
            widget.onPicked(workplace);
          },
          child: Container(
            color: isSelected ? AppTheme.colors.primary.withValues(alpha: .06) : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: ScreenSize.h12, horizontal: ScreenSize.h8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        workplace.name,
                        style: AppTheme.data.textTheme.titleSmall?.copyWith(
                          color: isSelected ? AppTheme.colors.primary : AppTheme.colors.blackSoft,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),

                      if (workplace.category.name.isNotEmpty) ...<Widget>[
                        Gap(ScreenSize.h2),
                        Text(workplace.category.name, style: AppTheme.data.textTheme.bodySmall),
                      ],
                    ],
                  ),
                ),

                if (isSelected) Icon(Icons.check_rounded, color: AppTheme.colors.primary, size: ScreenSize.h18),
              ],
            ),
          ),
        );
      },
    );
  }
}
