import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Ko'rish ekranidagi bo'lim. Sarlavhada nechta element borligi yoziladi.
final class ContractSection extends StatelessWidget {
  const ContractSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.count,
  });

  final String title;
  final String icon;
  final Widget child;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final int? total = count;

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
          Row(
            children: <Widget>[
              SvgPicture.asset(
                icon,
                height: ScreenSize.h18,
                colorFilter: ColorFilter.mode(AppTheme.colors.primary, BlendMode.srcIn),
              ),

              Gap(ScreenSize.w8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                ),
              ),

              if (total != null) Text("$total ta", style: AppTheme.data.textTheme.bodyMedium),
            ],
          ),

          Gap(ScreenSize.h12),
          child,
        ],
      ),
    );
  }
}

/// Shartnoma kimga tegishli ekani.
final class ContractClientCard extends StatelessWidget {
  const ContractClientCard({super.key, required this.name});

  final String name;

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
          Text("Mijoz", style: AppTheme.data.textTheme.bodySmall),

          Gap(ScreenSize.h2),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
          ),
        ],
      ),
    );
  }
}

final class ContractGuarantorRow extends StatelessWidget {
  const ContractGuarantorRow(this.guarantor, {super.key});

  final ContractGuarantor guarantor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenSize.h8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  guarantor.fullName.isEmpty ? "Ism ko'rsatilmagan" : guarantor.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
                ),

                if (guarantor.passport.isNotEmpty)
                  Text(guarantor.passport, style: AppTheme.data.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class ContractCardSection extends StatelessWidget {
  const ContractCardSection({super.key, required this.card});

  final ContractCard card;

  @override
  Widget build(BuildContext context) {
    return ContractSection(
      title: "Plastik karta",
      icon: AppIcons.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            card.number.isEmpty ? "Raqam ko'rsatilmagan" : card.number,
            style: AppTheme.data.textTheme.titleMedium?.copyWith(color: AppTheme.colors.blackSoft),
          ),

          if (card.expiry.isNotEmpty)
            Text("Amal qiladi: ${card.expiry}", style: AppTheme.data.textTheme.bodySmall),
          if (card.phone.isNotEmpty) Text(card.phone, style: AppTheme.data.textTheme.bodySmall),
        ],
      ),
    );
  }
}

final class ContractBenefitSection extends StatelessWidget {
  const ContractBenefitSection({super.key, required this.benefit});

  final ContractBenefit benefit;

  @override
  Widget build(BuildContext context) {
    return ContractSection(
      title: "Menejer bonusi",
      icon: AppIcons.star,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _row("Talab qilingan", benefit.requiredAmount),
          _row("Mavjud limit", benefit.availableAmount),
          _row("Ishlatilgan", benefit.usedAmount),
        ],
      ),
    );
  }

  Widget _row(String title, int amount) => Padding(
    padding: EdgeInsets.only(bottom: ScreenSize.h4),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(title, style: AppTheme.data.textTheme.bodySmall)),
        Text(
          Money.withUnit(amount),
          style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.blackSoft),
        ),
      ],
    ),
  );
}

/// Skoring rad etilganda sababi. Bo'sh bo'lsa umuman chizilmaydi.
final class ContractFailReasons extends StatelessWidget {
  const ContractFailReasons({super.key, required this.mib, required this.katm});

  final String mib;
  final String katm;

  @override
  Widget build(BuildContext context) {
    return ContractSection(
      title: "Rad etilish sababi",
      icon: AppIcons.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (mib.isNotEmpty) _reason("MIB", mib),
          if (katm.isNotEmpty) _reason("KATM", katm),
        ],
      ),
    );
  }

  Widget _reason(String source, String text) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: ScreenSize.h8),
    padding: EdgeInsets.all(ScreenSize.h10),
    decoration: BoxDecoration(
      color: AppTheme.colors.red.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(ScreenSize.r12),
      border: Border.all(color: AppTheme.colors.red.withValues(alpha: .2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          source,
          style: AppTheme.data.textTheme.bodySmall?.copyWith(
            color: AppTheme.colors.red,
            fontWeight: FontWeight.w700,
          ),
        ),

        Text(
          text,
          style: AppTheme.data.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400, height: 1.4),
        ),
      ],
    ),
  );
}
