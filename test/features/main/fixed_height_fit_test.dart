import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/features/main/presentation/widgets/bottom_item.dart';
import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Qat'iy balandlikdagi joylar matn shkalasi o'zgarganda toshmaydimi.
///
/// Figma shkalasiga o'tishda (12→14, 10→13 va qator balandligi 1.4–1.5)
/// pastki navigatsiya tizim shrifti 1.3× bo'lganda paneldan toshib ketdi.
/// Panel balandligi dizayn doimiysi, shuning uchun yozuvning kattalashuvi
/// 1.1 bilan chegaralangan.
Future<void> _check(WidgetTester tester, Size size, double scale, Widget child, String label) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;

  await tester.pumpWidget(
    ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
  );
  await AppTheme.init();
  ScreenSize.setSizes();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale), size: size),
        child: MaterialApp(theme: AppTheme.data, home: Scaffold(body: child)),
      ),
    ),
  );
  await tester.pump();

  expect(
    tester.takeException(),
    isNull,
    reason: '$label ${size.width.toInt()}x${size.height.toInt()} @$scale da toshdi',
  );
}

void main() {
  testWidgets('pastki panel va sarlavha hech qaysi o‘lchamda toshmaydi', (WidgetTester tester) async {
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    final Widget bar = SizedBox(
      height: ScreenSize.h80,
      child: Row(
        children: const <Widget>[
          Expanded(child: BottomItem(icon: AppIcons.customers, label: 'Mijozlar', isSelect: true, press: _noop)),
          Expanded(child: BottomItem(icon: AppIcons.contract, label: 'Shartnomalar', isSelect: false, press: _noop)),
          Expanded(child: BottomItem(icon: AppIcons.output, label: 'Chiqim tovar', isSelect: false, press: _noop)),
          Expanded(child: BottomItem(icon: AppIcons.file, label: 'Fakturalar', isSelect: false, press: _noop)),
        ],
      ),
    );

    for (final double scale in <double>[1.0, 1.3]) {
      for (final Size size in <Size>[const Size(393, 852), const Size(360, 640)]) {
        await _check(tester, size, scale, bar, 'bottom-nav');
        await _check(tester, size, scale,
            PageHeader(title: 'Shartnomani imzolash', topInset: 54, backPress: _noop), 'page-header');
      }
    }
  });
}

void _noop() {}
