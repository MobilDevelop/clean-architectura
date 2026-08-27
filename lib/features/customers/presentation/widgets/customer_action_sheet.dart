import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_divider.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_item.dart';
import 'package:colloborator_v3/core/widgets/sheets/action_sheet.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_avatar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Mijoz ustidagi amallar oynasi.
///
/// Sahifa qaysi amal nima qilishini beradi — oyna faqat ko'rsatadi (6.7).
Future<void> showCustomerActions({required BuildContext context,
  required CustomerInfo info,
  required VoidCallback pressScoring,
  required VoidCallback pressContract,
  required VoidCallback pressEdit,
  required VoidCallback pressInfo,
}) => showActionSheet(
  context: context,
  header: _CustomerSheetHeader(info: info),
  actions: <Widget>[
    ActionItem(
      icon: AppIcons.contract,
      color: AppTheme.colors.primary,
      title: "Shartnoma tuzish",
      subtitle: "Yangi shartnomani boshlash",
      onTap: pressContract,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.graphic,
      color: AppTheme.colors.blue,
      title: "Skoring natijasi",
      subtitle: "KATM va MIB bo'yicha tekshiruv",
      onTap: pressScoring,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.edit,
      color: AppTheme.colors.yellow,
      title: "Tahrirlash",
      subtitle: "Mijoz ma'lumotini o'zgartirish",
      onTap: pressEdit,
    ),

    const ActionDivider(),
    ActionItem(
      icon: AppIcons.info,
      color: AppTheme.colors.grey,
      title: "Batafsil ma'lumot",
      subtitle: "To'liq ma'lumotni ko'rish",
      onTap: pressInfo,
    ),
  ],
);

/// Oyna sarlavhasi — amallar kimga tegishli ekanini ko'rsatadi.
final class _CustomerSheetHeader extends StatelessWidget {
  const _CustomerSheetHeader({required this.info});

  final CustomerInfo info;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CustomerAvatar(fullName: info.fullName, size: ScreenSize.h52),

        Gap(ScreenSize.w12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                info.fullName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.blackSoft, letterSpacing: -0.2),
              ),

              Gap(ScreenSize.h4),
              Text(
                "INPS · ${info.inps}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.data.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
