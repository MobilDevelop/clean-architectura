import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contract_create/presentation/shared/imei_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kartada raqamlar yalang'och turgan edi — nima ekani ko'rinmasdi.
void main() {
  testWidgets('raqamlar «IMEI» yorlig\'i bilan ko\'rsatiladi', (WidgetTester tester) async {
    await _pump(tester, const <String>['111111111111111', '222222222222222']);

    expect(find.text('IMEI'), findsOneWidget);
    expect(find.text('111111111111111'), findsOneWidget);
    expect(find.text('222222222222222'), findsOneWidget);
  });

  /// Ikkita IMEI — bitta qurilma (ikki SIM). «2» soni dona deb o'qilardi.
  testWidgets('raqamlar soni dona soni bo\'lib ko\'rinmaydi', (WidgetTester tester) async {
    await _pump(tester, const <String>['111111111111111', '222222222222222']);

    expect(find.text('2'), findsNothing);
    expect(find.text('2 ta'), findsNothing);
  });

  testWidgets('raqam bo\'lmasa hech nima chizilmaydi', (WidgetTester tester) async {
    await _pump(tester, const <String>[]);

    expect(find.text('IMEI'), findsNothing);
  });
}

Future<void> _pump(WidgetTester tester, List<String> values) async {
  const Size screen = Size(393, 852);

  await tester.pumpWidget(
    ScreenUtilInit(designSize: screen, builder: (_, _) => const SizedBox.shrink()),
  );
  await AppTheme.init();
  ScreenSize.setSizes();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: screen,
      builder: (_, _) => MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(body: ImeiList(values: values, chipColor: AppTheme.colors.white)),
      ),
    ),
  );
  await tester.pump();
}
