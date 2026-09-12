import 'dart:async';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/services/app_info.dart';
import 'package:colloborator_v3/core/services/auth_notifier.dart';
import 'package:colloborator_v3/core/session/app_user.dart';
import 'package:colloborator_v3/core/session/session_store.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/utils/formatter/phone_formatter.dart';
import 'package:colloborator_v3/core/widgets/dialogs/app_dialog.dart';
import 'package:colloborator_v3/core/widgets/drawer/drawer_text.dart';
import 'package:colloborator_v3/core/widgets/drawer/drawer_tile.dart';
import 'package:colloborator_v3/core/widgets/toasts/custom_animated_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

/// Yon menyu.
///
/// Nega `core/widgets/` da: uni mijozlar va shartnomalar ekranlari ochadi,
/// ya'ni u bitta featurega tegishli emas (1.2).
///
/// Bo'limlarning ekranlari hali yozilmagan. Ular yashirilmaydi: xodim ilovada
/// nima borligini ko'rib turishi kerak, «tez orada» belgisi esa bosishdan
/// oldin holatni aytadi (5.8).
final class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.read<SessionStore>().user;

    // Versiya ishga tushishda bir marta o'qilgan (`AppStartup`).
    final String version = context.read<AppInfo>().version;

    return Drawer(
      backgroundColor: AppTheme.colors.backcolor,
      width: MediaQuery.sizeOf(context).width * .82,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(ScreenSize.r30)),
      ),
      // Ustki chekka `SafeArea` ga berilmaydi: gradient ekranning eng
      // tepasiga chiqishi kerak. Status bar balandligi sarlavhaning **ichiga**
      // padding bo'lib qo'shiladi, ya'ni matn baribir uning ostida qolmaydi.
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            _header(user, MediaQuery.paddingOf(context).top),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(ScreenSize.h12, ScreenSize.h14, ScreenSize.h12, ScreenSize.h8),
                children: <Widget>[
                  // Prescoring huquqi bo'lmagan xodimda bo'lim umuman
                  // ko'rinmaydi — u uchun bu ilovaning imkoniyati emas.
                  if (user?.permissions.showPrescoring ?? false)
                    DrawerTile(
                      title: DrawerText.analysis,
                      icon: AppIcons.graphic,
                      accent: AppTheme.colors.blue,
                      mark: DrawerTileMark.soon,
                      onTap: () => _notReady(context, DrawerText.analysis),
                    ),

                  DrawerTile(
                    title: DrawerText.calculator,
                    icon: '',
                    materialIcon: Icons.calculate_outlined,
                    accent: AppTheme.colors.primary,
                    mark: DrawerTileMark.soon,
                    onTap: () => _notReady(context, DrawerText.calculator),
                  ),

                  DrawerTile(
                    title: DrawerText.password,
                    icon: AppIcons.refresh,
                    accent: AppTheme.colors.yellow,
                    mark: DrawerTileMark.soon,
                    onTap: () => _notReady(context, DrawerText.password),
                  ),

                  DrawerTile(
                    title: DrawerText.support,
                    icon: '',
                    materialIcon: Icons.support_agent_outlined,
                    accent: AppTheme.colors.secondary,
                    mark: DrawerTileMark.soon,
                    onTap: () => _notReady(context, DrawerText.support),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h12),
              child: DrawerTile(
                title: DrawerText.logout,
                icon: AppIcons.logout,
                accent: AppTheme.colors.red,
                // Chiqish — amal, boshqa ekranga o'tilmaydi.
                mark: DrawerTileMark.none,
                onTap: () => unawaited(_confirmLogout(context)),
              ),
            ),

            Gap(ScreenSize.h4),
            Text(
              DrawerText.version(version),
              style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.grey),
            ),

            Gap(ScreenSize.h10),
          ],
        ),
      ),
    );
  }

  /// Sarlavha: bosh harflar, ism, tashkilot, lavozim va telefon.
  ///
  /// Menyuning katta qismini shu egallaydi — xodim menyuni ochganda birinchi
  /// navbatda kim sifatida kirganini ko'radi. Flex'da bu yerda cho'zilib
  /// ketadigan fon rasmi turadi va u turli ekran nisbatlarida qiyshayadi;
  /// bu yerda rasm yo'q, rang mavzudan olinadi.
  Widget _header(User? user, double topInset) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      ScreenSize.h20,
      topInset + ScreenSize.h20,
      ScreenSize.h20,
      ScreenSize.h24,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppTheme.colors.primary.withValues(alpha: .18),
          AppTheme.colors.blue.withValues(alpha: .08),
        ],
      ),
      border: Border(bottom: BorderSide(color: AppSurface.line())),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: ScreenSize.h72,
              width: ScreenSize.h72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .35), width: ScreenSize.h2),
              ),
              child: Text(
                DrawerText.initials(user?.fio ?? ''),
                style: AppTheme.data.textTheme.displayLarge?.copyWith(
                  color: AppTheme.colors.primary,
                  fontSize: ScreenSize.sp24,
                ),
              ),
            ),

            Gap(ScreenSize.w14),
            // Chip matn bo'yicha qisqaradi: `Expanded` bilan u butun
            // kenglikni egallab, bo'sh kapsula bo'lib ko'rinardi.
            if ((user?.rule ?? '').isNotEmpty)
              Flexible(child: _roleChip(user?.rule ?? '')),
          ],
        ),

        Gap(ScreenSize.h16),
        Text(
          user?.fio ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.data.textTheme.displayLarge?.copyWith(color: AppTheme.colors.black),
        ),

        if ((user?.organization ?? '').isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h6),
          _line(AppIcons.workplace, user?.organization ?? ''),
        ],

        if ((user?.phone ?? '').isNotEmpty) ...<Widget>[
          Gap(ScreenSize.h6),
          _line(AppIcons.phone, PhoneFormatter.mask(user?.phone ?? '')),
        ],
      ],
    ),
  );

  /// Ikonka va matn — tashkilot va telefon qatorlari uchun.
  Widget _line(String icon, String value) => Row(
    children: <Widget>[
      SvgPicture.asset(
        icon,
        height: ScreenSize.h14,
        colorFilter: ColorFilter.mode(AppTheme.colors.grey, BlendMode.srcIn),
      ),

      Gap(ScreenSize.w8),
      Expanded(
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTheme.data.textTheme.bodyMedium,
        ),
      ),
    ],
  );

  Widget _roleChip(String role) => Container(
    padding: EdgeInsets.symmetric(horizontal: ScreenSize.h10, vertical: ScreenSize.h6),
    decoration: BoxDecoration(
      color: AppTheme.colors.white,
      borderRadius: BorderRadius.circular(ScreenSize.r10),
      border: Border.all(color: AppTheme.colors.primary.withValues(alpha: .35)),
    ),
    child: Text(
      role,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: AppTheme.data.textTheme.bodySmall?.copyWith(color: AppTheme.colors.primary),
    ),
  );

  Future<void> _notReady(BuildContext context, String title) async {
    Navigator.of(context).pop();

    await CustomAnimatedToast.showInfo(DrawerText.notReady(title));
  }

  /// Chiqish qaytarilmaydi, shuning uchun tasdiq so'raladi.
  Future<void> _confirmLogout(BuildContext context) async {
    final AuthNotifier auth = context.read<AuthNotifier>();

    Navigator.of(context).pop();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AppDialog(
        icon: AppIcons.logout,
        accent: AppTheme.colors.red,
        title: DrawerText.logoutTitle,
        message: DrawerText.logoutMessage,
        actionLabel: DrawerText.logoutAction,
        cancelLabel: "Bekor qilish",
        onAction: () {
          Navigator.of(dialogContext).pop();
          unawaited(auth.signOut());
        },
      ),
    );
  }
}
