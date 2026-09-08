import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/special_tariff.dart';
import 'package:colloborator_v3/features/contract_create/presentation/tariff/special_tariff_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/spoke_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

/// Maxsus tarif.
///
/// Ro'yxat shartnoma summasi va muddatiga bog'liq, shuning uchun tovar
/// o'zgarganda biriktirilgan tarif bekor qilinadi. Bekor qilingani markazdagi
/// qatorda darhol ko'rinadi.
final class SpecialTariffPage extends StatelessWidget {
  const SpecialTariffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpecialTariffBloc, SpecialTariffState>(
      builder: (BuildContext context, SpecialTariffState state) {
        final SpecialTariffBloc bloc = context.read<SpecialTariffBloc>();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (!didPop) context.pop(state.revision > 0);
          },
          child: SpokeScaffold(
            title: "Maxsus tarif",
            failure: state.failure,
            failureHandled: () => bloc.add(const FailureHandled()),
            retryPress: () => bloc.add(const Retried()),
            backPress: () => context.pop(state.revision > 0),
            isLoading: state.isLoading && !state.isLoaded,
            child: ListView(
              padding: EdgeInsets.fromLTRB(ScreenSize.h16, ScreenSize.h16, ScreenSize.h16, ScreenSize.h24),
              children: <Widget>[
                if (state.hasApplied) _applied(context, state, bloc),

                if (state.isLoaded && state.tariffs.isEmpty)
                  Text(
                    "Bu shartnoma uchun mos maxsus tarif topilmadi",
                    style: AppTheme.data.textTheme.bodySmall,
                  ),

                for (final SpecialTariff item in state.tariffs)
                  _card(
                    item,
                    isBusy: state.busyTariffId == item.id,
                    isApplied: state.applied.id == item.id,
                    onTap: () => bloc.add(TariffApplied(item.id)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _applied(BuildContext context, SpecialTariffState state, SpecialTariffBloc bloc) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: ScreenSize.h14),
    padding: EdgeInsets.all(ScreenSize.h14),
    decoration: BoxDecoration(
      color: AppTheme.colors.primary.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .3)),
    ),
    child: Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                state.applied.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.primary),
              ),
              Gap(ScreenSize.h2),
              Text(
                state.applied.isActive ? "Biriktirilgan · faol" : "Biriktirilgan",
                style: AppTheme.data.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        if (state.isRemoving)
          SizedBox(
            width: ScreenSize.h20,
            height: ScreenSize.h20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
          )
        else
          TextButton(
            onPressed: () => bloc.add(const TariffRemoved()),
            child: Text(
              "Bekor qilish",
              style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.red),
            ),
          ),
      ],
    ),
  );

  Widget _card(
    SpecialTariff tariff, {
    required bool isBusy,
    required bool isApplied,
    required VoidCallback onTap,
  }) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h10),
    child: InkWell(
      onTap: isBusy || isApplied ? null : onTap,
      borderRadius: BorderRadius.circular(ScreenSize.r18),
      child: Container(
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r18),
          border: AppSurface.border(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    tariff.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
                  ),
                ),

                if (isBusy)
                  SizedBox(
                    width: ScreenSize.h18,
                    height: ScreenSize.h18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.colors.primary),
                  )
                else if (isApplied)
                  Icon(Icons.check_circle, size: ScreenSize.h20, color: AppTheme.colors.primary),
              ],
            ),

            Gap(ScreenSize.h8),
            _line("Oldingi marja", "${tariff.frontMargin}%"),
            _line("Boshlang'ich to'lov", "${tariff.prepaymentPercent}%"),
            _line(
              "Choraklik marja",
              tariff.quarters.map((double e) => "$e%").join(" · "),
            ),

            if (tariff.startsAt.isNotEmpty || tariff.endsAt.isNotEmpty)
              _line("Amal muddati", "${tariff.startsAt} — ${tariff.endsAt}"),
          ],
        ),
      ),
    ),
  );

  Widget _line(String title, String value) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: Text(title, style: AppTheme.data.textTheme.bodySmall)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.blackSoft),
          ),
        ),
      ],
    ),
  );
}
