import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/inputs/sms_code_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Belgilar to'plami, klaviatura va uzunlik bitta manbadan chiqishini
/// qulflaydi — ilgari ular uch ekranda alohida yozilib, uzilib qolgan edi.
void main() {
  testWidgets('raqamli kodga harf tushmaydi va uzunligidan oshmaydi', (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller: controller, length: 5);
    await tester.enterText(find.byType(TextField), '12ab345');

    expect(controller.text, '12345');
  });

  testWidgets('har belgi o\'z katagida ko\'rinadi', (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    await _pump(tester, controller: controller, length: 5);
    await tester.enterText(find.byType(TextField), '307');
    await tester.pump();

    // Kodni eshitib yozayotgan xodim har raqamni alohida ko'radi.
    expect(find.text('3'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
  });

  testWidgets('uzunlik berilmasa kod kesilmaydi, lekin harf baribir tushmaydi', (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();
    addTearDown(controller.dispose);

    // Uzunlik noma'lum bo'lgan holat: kodni kesib qo'yish uni yo'q qilardi.
    await _pump(tester, controller: controller, hint: '6 xonali kod');
    await tester.enterText(find.byType(TextField), '12ab345678');

    expect(controller.text, '12345678');
  });
}

Future<void> _pump(
  WidgetTester tester, {
  required TextEditingController controller,
  int? length,
  String? hint,
}) async {
  await tester.pumpWidget(ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()));
  await AppTheme.init();
  ScreenSize.setSizes();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(
          body: SmsCodeField(
            controller: controller,
            kind: SmsCodeKind.digits,
            length: length,
            hint: hint,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}
