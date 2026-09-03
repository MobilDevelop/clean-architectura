import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_avatar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Formaning tepasidagi karta: kimning ma'lumoti to'ldirilayotgani.
///
/// Nega kerak: tahrirlashda ekranda faqat bo'sh maydonlar turardi va agent
/// qaysi mijozni ochganini ko'rmasdi.
final class CustomerSummaryCard extends StatelessWidget {
  const CustomerSummaryCard({super.key, required this.info});

  final CustomerInfo info;

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
        boxShadow: AppShadow.card(),
      ),
      child: Row(
        children: <Widget>[
          CustomerAvatar(fullName: info.fullName),

          Gap(ScreenSize.w12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  info.fullName.isEmpty ? "Ism ko'rsatilmagan" : info.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.blackSoft),
                ),

                Gap(ScreenSize.h4),
                Wrap(
                  spacing: ScreenSize.w10,
                  runSpacing: ScreenSize.h2,
                  children: <Widget>[
                    if (info.passportNumber.isNotEmpty)
                      Text(info.passportNumber, style: AppTheme.data.textTheme.bodyMedium),
                    if (info.birthDay.isNotEmpty) Text(info.birthDay, style: AppTheme.data.textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
