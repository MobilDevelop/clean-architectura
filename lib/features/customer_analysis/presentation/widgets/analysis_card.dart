import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/utils/money.dart';
import 'package:colloborator_v3/core/widgets/cards/labeled_row.dart';
import 'package:colloborator_v3/features/customer_analysis/domain/entities/customer_analysis.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_status_style.dart';
import 'package:colloborator_v3/features/customer_analysis/presentation/styles/analysis_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Tahlil kartasi. SMS kutilayotgan yozuvda bosilsa tasdiqlash oynasi
/// ochiladi — qaror sahifada, karta faqat ko'rsatadi (6.7).
final class AnalysisCardTile extends StatelessWidget {
  const AnalysisCardTile({
    super.key,
    required this.item,
    required this.isConfirming,
    required this.onTap,
  });

  final CustomerAnalysis item;

  /// Shu yozuvning SMS kodi hozir tasdiqlanmoqda.
  final bool isConfirming;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h12),
        padding: EdgeInsets.all(ScreenSize.h14),
        decoration: BoxDecoration(
          color: AppTheme.colors.white,
          borderRadius: BorderRadius.circular(ScreenSize.r20),
          border: AppSurface.border(),
          boxShadow: AppShadow.card(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _header(),

            LabeledRow(
              label: AnalysisText.inpsRowLabel,
              value: Text(
                item.inps,
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
              ),
            ),

            if (item.phone.isNotEmpty)
              LabeledRow(
                label: AnalysisText.phoneRowLabel,
                value: Text(
                  PhoneFormatter.mask(item.phone),
                  style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.black),
                ),
              ),

            LabeledRow(
              label: AnalysisText.limitRowLabel,
              value: Text(
                Money.withUnit(item.freeLimit),
                style: AppTheme.data.textTheme.titleLarge?.copyWith(color: AppTheme.colors.primary),
              ),
            ),

            LabeledRow(
              label: AnalysisText.statusLabel,
              isLast: true,
              value: _StatusChip(
                label: AnalysisStatusStyle.label(item.status),
                color: AnalysisStatusStyle.color(item.status),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        height: ScreenSize.h44,
        width: ScreenSize.h44,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppTheme.colors.grey1)),
        child: SvgPicture.asset(
          AppIcons.graphic,
          height: ScreenSize.h20,
          colorFilter: ColorFilter.mode(AnalysisStatusStyle.color(item.status), BlendMode.srcIn),
        ),
      ),

      Gap(ScreenSize.w12),
      Expanded(
        child: Text(
          item.fullName.isEmpty ? AnalysisText.noName : item.fullName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.data.textTheme.headlineLarge?.copyWith(
            color: AppTheme.colors.black,
            letterSpacing: -0.2,
          ),
        ),
      ),

      Gap(ScreenSize.w6),
      if (isConfirming)
        SizedBox(
          height: ScreenSize.h20,
          width: ScreenSize.h20,
          child: CircularProgressIndicator(color: AppTheme.colors.primary, strokeWidth: ScreenSize.h2),
        )
      else if (item.status.needsSmsCode)
        Icon(Icons.chevron_right_rounded, color: AppTheme.colors.grey, size: ScreenSize.h22),
    ],
  );
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12, vertical: ScreenSize.h6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(ScreenSize.r10),
      ),
      child: Text(label, style: AppTheme.data.textTheme.titleLarge?.copyWith(color: color)),
    );
  }
}
