import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mavzudagi shrift oilasi `pubspec.yaml` da e'lon qilingan bo'lishi kerak.
///
/// Nima bo'lgan edi: mavzuda `BetaniaPatmos-Regular` yozilgan, lekin u
/// `pubspec.yaml` ning `fonts:` bo'limida umuman yo'q edi. Flutter e'lon
/// qilinmagan oilani topa olmaydi va **jimgina** tizim shriftiga tushadi:
/// ilova Figma shriftida ham, paketga qo'shilgan NotoSans'da ham chizilmasdi,
/// hech qanday xato ham bermasdi.
///
/// `assets/fonts/` ni `assets:` ga qo'shish shriftni ro'yxatga olmaydi —
/// u faqat fayllarni xom asset qilib yuklaydi.
const String _declaredFamily = 'NotoSans';

void main() {
  testWidgets('mavzu e‘lon qilingan shrift oilasini ishlatadi', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
    );
    await AppTheme.init();

    expect(AppTheme.data.textTheme.bodyMedium?.fontFamily, _declaredFamily);
    expect(AppTheme.data.textTheme.displayLarge?.fontFamily, _declaredFamily);
  });
}
