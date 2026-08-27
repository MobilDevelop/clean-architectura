import 'package:bounce/bounce.dart';
import 'package:colloborator_v3/core/constants/app_constants.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_shadow.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_avatar.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_chip.dart';
import 'package:colloborator_v3/core/widgets/info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

/// Mijoz kartasi.
///
/// Karta hech qanday qaror qabul qilmaydi: bosilganda nima bo'lishini
/// tashqaridan oladi (6.7). Amallar kartaning ichida emas, amal oynasida.
final class CustomerInfoWidget extends StatelessWidget {
  const CustomerInfoWidget({super.key, required this.info, required this.pressActions});

  final CustomerInfo info;
  final VoidCallback pressActions;

  @override
  Widget build(BuildContext context) {
    return Bounce(
      duration: Duration(milliseconds: AppConstants.duration),
      onTap: pressActions,
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
            Row(
              children: <Widget>[
                CustomerAvatar(fullName: info.fullName),

                Gap(ScreenSize.w12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        info.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.data.textTheme.headlineLarge?.copyWith(
                          color: AppTheme.colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),

                      Gap(ScreenSize.h5),
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              "INPS · ${info.inps}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.data.textTheme.bodyMedium,
                            ),
                          ),

                          Gap(ScreenSize.w8),
                          CustomerChip(label: info.passportType ? "ID karta" : "Biometrik"),
                        ],
                      ),
                    ],
                  ),
                ),

                Gap(ScreenSize.w6),
                // Nega alohida bosish emas: butun karta bosiladi, bu belgi
                // faqat "bu yerda amallar bor" deb turadi.
                SvgPicture.asset(
                  AppIcons.points,
                  height: ScreenSize.h20,
                  colorFilter: ColorFilter.mode(AppTheme.colors.grey.withValues(alpha: .7), BlendMode.srcIn),
                ),
              ],
            ),

            Gap(ScreenSize.h14),
            Row(
              children: <Widget>[
                Expanded(
                  child: InfoTile(icon: AppIcons.calendar, label: "Tug'ilgan sana", value: info.birthDay),
                ),

                Gap(ScreenSize.w8),
                Expanded(
                  child: InfoTile(icon: AppIcons.passport, label: "Pasport raqami", value: info.passportNumber),
                ),
              ],
            ),

            Gap(ScreenSize.h8),
            InfoTile(
              icon: AppIcons.phone,
              label: "Telefon raqami",
              value: info.mainPhone?.phone ?? "Telefon raqam mavjud emas",
              // Nega: raqam yo'qligi ham ma'lumot — u xuddi raqamdek ko'rinmasligi kerak.
              isEmpty: info.mainPhone == null,
            ),
          ],
        ),
      ),
    );
  }
}
