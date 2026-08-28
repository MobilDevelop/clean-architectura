import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/states/empty_placeholder.dart';
import 'package:flutter/material.dart';

/// Mavjud bo'lmagan manzilga o'tilganda ko'rsatiladigan ekran.
///
/// Nega bo'sh `SizedBox` emas: marshrut xatosida ekran oqarib qoladi va
/// foydalanuvchi ilova osilib qolgan deb o'ylaydi. Bu yerda hech bo'lmasa
/// nima bo'lgani aytiladi va qaytish yo'li ko'rsatiladi.
final class RouteErrorView extends StatelessWidget {
  const RouteErrorView({super.key, required this.location, required this.onBack});

  /// Topilmagan manzil — nosozlikni tushunish uchun kerak.
  final String location;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.backcolor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            EmptyPlaceholder(
              icon: AppIcons.warning,
              title: "Sahifa topilmadi",
              message: location.isEmpty ? "So'ralgan sahifa mavjud emas" : "So'ralgan sahifa mavjud emas: $location",
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ScreenSize.h32),
              child: MainButton(text: "Asosiy sahifaga qaytish", onPressed: onBack),
            ),
          ],
        ),
      ),
    );
  }
}
