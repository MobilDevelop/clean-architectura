import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_surface.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shartnoma fayli ustidagi amallar — ekranning pastida qotib turadi.
///
/// Nega ro'yxat ichida emas: tovarlar, kafillar va karta bo'limlaridan keyin
/// ular ekranning eng pastiga tushib ketardi va topilmasdi. Fayl — shu
/// ekrandagi yagona amal, u har doim ko'rinib turishi kerak.
final class ContractFileBar extends StatelessWidget {
  const ContractFileBar({
    super.key,
    required this.hasFile,
    required this.isSharing,
    required this.openPress,
    required this.sharePress,
  });

  /// Serverda fayl bormi.
  final bool hasFile;

  final bool isSharing;
  final VoidCallback openPress;
  final VoidCallback sharePress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.colors.white,
        border: Border(top: BorderSide(color: AppSurface.line())),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: ScreenSize.h14, vertical: ScreenSize.h10),
          // Fayl yo'qligi ham ma'lumot: bo'sh joy o'rniga sabab turadi (5.8).
          child: hasFile ? _actions() : _empty(),
        ),
      ),
    );
  }

  /// Ikkalasi teng: `3:1` da ulashish tugmasiga 57px qolib, ikon bilan matn
  /// sig'may qolgan edi. Lokalizatsiyada matn yana uzayadi (kiril va rus
  /// lotindan 15–30% uzun), shuning uchun tor ustun umuman qoldirilmaydi.
  Widget _actions() => Row(
    children: <Widget>[
      Expanded(
        child: MainButton(text: "Faylni ochish", leftIcon: AppIcons.file, onPressed: openPress),
      ),

      Gap(ScreenSize.w10),
      Expanded(
        child: MainButton(
          text: "Ulashish",
          leftIcon: AppIcons.share,
          color: AppTheme.colors.blue.withValues(alpha: .1),
          textColor: AppTheme.colors.blue,
          borderColor: AppTheme.colors.blue,
          showLoading: isSharing,
          onPressed: sharePress,
        ),
      ),
    ],
  );

  Widget _empty() => Text(
    "Shartnoma fayli hali tayyor emas",
    textAlign: TextAlign.center,
    style: AppTheme.data.textTheme.bodyMedium?.copyWith(color: AppTheme.colors.grey),
  );
}
