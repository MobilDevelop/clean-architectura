import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:flutter/material.dart';

/// Mijozlar ekranining foni.
///
/// Nega chiziqli gradient emas: ekran bo'ylab cho'zilgan gradientda ranglar
/// bir-biriga o'tayotgani ko'zga tashlanadi. Bu yerda tekis fon ustiga ikkita
/// burchakdagi yoritma qo'yiladi va ular o'z rangining shaffofiga so'nadi —
/// shuning uchun hech qanday chegara chizig'i qolmaydi.
final class BackgroundWash extends StatelessWidget {
  const BackgroundWash({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: ColoredBox(color: AppTheme.colors.backcolor)),

        Positioned(
          top: -ScreenSize.h140,
          right: -ScreenSize.h110,
          child: _Glow(color: AppTheme.colors.primary, size: ScreenSize.h300, alpha: .07),
        ),

        Positioned(
          bottom: -ScreenSize.h160,
          left: -ScreenSize.h130,
          child: _Glow(color: AppTheme.colors.blue, size: ScreenSize.h300, alpha: .04),
        ),
      ],
    );
  }
}

/// Yumshoq dumaloq yoritma — fonning o'zidan boshqa joyda ma'nosi yo'q,
/// shuning uchun shu faylda qoladi.
final class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size, required this.alpha});

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: alpha),
              // Nega `Colors.transparent` emas: u shaffof QORA, ya'ni oraliq
              // ranglar kulrangga bo'yaladi va aynan shu chiziq bo'lib ko'rinadi.
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
