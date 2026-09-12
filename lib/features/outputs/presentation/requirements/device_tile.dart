import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/presentation/requirements/requirements_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// iCloud ma'lumoti talab qilinadigan qurilma.
final class DeviceTile extends StatelessWidget {
  const DeviceTile({super.key, required this.device, required this.onTap});

  final IcloudDevice device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isFilled = device.isFilled;

    return Container(
      margin: EdgeInsets.only(left: ScreenSize.h12, right: ScreenSize.h12, bottom: ScreenSize.h10),
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        border: AppSurface.border(),
        boxShadow: AppShadow.card(),
      ),
      child: InkWell(
        // To'ldirilgan qurilma qayta ochilmaydi — yozuv serverda allaqachon bor.
        onTap: isFilled ? null : onTap,
        borderRadius: BorderRadius.circular(ScreenSize.r18),
        child: Padding(
          padding: EdgeInsets.all(ScreenSize.h14),
          child: Row(
            children: <Widget>[
              Container(
                height: ScreenSize.h44,
                width: ScreenSize.h44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.colors.grey1),
                ),
                child: Icon(
                  Icons.phone_iphone_rounded,
                  size: ScreenSize.h22,
                  color: isFilled ? AppTheme.colors.grey : AppTheme.colors.primary,
                ),
              ),

              Gap(ScreenSize.w12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      RequirementsText.deviceLabel,
                      style: AppTheme.data.textTheme.titleSmall?.copyWith(color: AppTheme.colors.grey),
                    ),

                    Text(
                      device.name,
                      style: AppTheme.data.textTheme.headlineLarge?.copyWith(color: AppTheme.colors.black),
                    ),

                    if (device.fullName.isNotEmpty) ...<Widget>[
                      Gap(ScreenSize.h2),
                      Text(device.fullName, style: AppTheme.data.textTheme.bodySmall),
                    ],

                    if (device.imei.isNotEmpty) ...<Widget>[
                      Gap(ScreenSize.h2),
                      Text(
                        "IMEI: ${device.imei}",
                        style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
                      ),
                    ],
                  ],
                ),
              ),

              Gap(ScreenSize.w8),
              if (isFilled) _filled() else Icon(Icons.chevron_right_rounded, color: AppTheme.colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filled() => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
    decoration: BoxDecoration(
      color: AppTheme.colors.green.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(ScreenSize.r12),
    ),
    child: Text(
      RequirementsText.filled,
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.green),
    ),
  );
}
