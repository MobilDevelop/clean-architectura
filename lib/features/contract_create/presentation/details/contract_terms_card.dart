import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Shartnoma shartlari: summa, muddat, to'lov kuni va daromad turi.
final class ContractTermsCard extends StatelessWidget {
  const ContractTermsCard({super.key, required this.details});

  final ContractDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: ScreenSize.h14),
      padding: EdgeInsets.all(ScreenSize.h14),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r20),
        border: AppSurface.border(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenSize.h12),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(ScreenSize.r16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("Shartnoma summasi", style: AppTheme.data.textTheme.bodyMedium),

                Gap(ScreenSize.h4),
                Text(
                  Money.withUnit(details.total),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.displayLarge?.copyWith(
                    color: AppTheme.colors.primary,
                    fontSize: ScreenSize.sp22,
                  ),
                ),
              ],
            ),
          ),

          Gap(ScreenSize.h12),
          Row(
            children: <Widget>[
              Expanded(child: _tile(AppIcons.calendar, "Muddat", "${details.termMonths} oy")),

              Gap(ScreenSize.w10),
              Expanded(child: _tile(AppIcons.calendar, "To'lov kuni", "${details.paymentDay}-kun")),
            ],
          ),

          Gap(ScreenSize.h10),
          Wrap(
            spacing: ScreenSize.w8,
            runSpacing: ScreenSize.h6,
            children: <Widget>[
              _chip(details.isFormal ? "Rasmiy daromad" : "Norasmiy daromad", AppTheme.colors.blue),
              if (details.hasCarIncome) _chip("Avto daromad", AppTheme.colors.blue),
              if (!details.tariff.isEmpty) _chip(details.tariff.name, AppTheme.colors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(String icon, String label, String value) => Container(
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.backcolor,
      borderRadius: BorderRadius.circular(ScreenSize.r14),
    ),
    child: Row(
      children: <Widget>[
        SvgPicture.asset(
          icon,
          height: ScreenSize.h16,
          colorFilter: ColorFilter.mode(AppTheme.colors.grey, BlendMode.srcIn),
        ),

        Gap(ScreenSize.w8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(label, style: AppTheme.data.textTheme.bodySmall),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.titleSmall?.copyWith(
                  color: AppTheme.colors.blackSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _chip(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(ScreenSize.r10),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Text(
      label,
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
    ),
  );
}
