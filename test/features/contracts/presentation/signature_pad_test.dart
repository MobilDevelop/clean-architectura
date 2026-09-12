import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Imzo maydoni chizilganini ko'rsatishi kerak.
///
/// Ikkita xato bir vaqtda imzoni ko'rinmas qilgan edi:
///
/// 1. `GestureDetector` ning sukut xatti-harakati `deferToChild` — u faqat
///    bolaning egallagan joyini hisobga oladi. Ko'rsatma matni maydonning
///    o'rtasida, chizilgandan keyin esa bola umuman yo'q: barmoq maydonning
///    katta qismida sezilmasdi.
/// 2. `shouldRepaint` nuqtalar ro'yxatining uzunligini solishtirardi, lekin
///    ro'yxat joyida o'zgartiriladi — ya'ni eski va yangi `points` bitta
///    obyekt va solishtiruv doim "o'zgarmadi" deb javob berardi.
Future<void> _pump(WidgetTester tester, GlobalKey<SignaturePadState> key) async {
  await tester.pumpWidget(
    ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
  );
  await AppTheme.init();
  ScreenSize.setSizes();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MaterialApp(
        theme: AppTheme.data,
        home: Scaffold(body: Center(child: SizedBox(height: 200, width: 300, child: SignaturePad(key: key, isLocked: false)))),
      ),
    ),
  );
}

Future<void> _draw(WidgetTester tester, Offset from, Offset to) async {
  final TestGesture gesture = await tester.startGesture(from);
  await gesture.moveTo(Offset.lerp(from, to, .5) ?? to);
  await gesture.moveTo(to);
  await gesture.up();
  await tester.pump();
}

void main() {
  testWidgets('maydonning chetida ham chiziladi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();
    await _pump(tester, key);

    final Rect pad = tester.getRect(find.byType(SignaturePad));

    // Ko'rsatma matnidan uzoq — ilgari aynan shu joyda barmoq sezilmasdi.
    await _draw(tester, pad.topLeft + const Offset(12, 12), pad.topLeft + const Offset(90, 30));

    expect(key.currentState?.hasSignature, isTrue);
  });

  testWidgets('ikkinchi chiziq ham qabul qilinadi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();
    await _pump(tester, key);

    final Rect pad = tester.getRect(find.byType(SignaturePad));
    await _draw(tester, pad.center - const Offset(40, 0), pad.center);

    // Birinchi chiziqdan keyin ko'rsatma matni yo'qoladi va `CustomPaint`
    // bolasiz qoladi — `deferToChild` bilan bu yer butunlay o'lik bo'lardi.
    await _draw(tester, pad.center, pad.center + const Offset(40, 20));

    // `export()` `ui.Image.toByteData()` ni chaqiradi — u haqiqiy hodisa
    // halqasini talab qiladi va `runAsync` siz test muhitida hech qachon
    // tugamaydi.
    final Uint8List? png = await tester.runAsync<Uint8List?>(() => key.currentState!.export());

    expect(png, isNotNull);
    expect(png!.isNotEmpty, isTrue);
  });

  testWidgets('bo‘sh maydon PNG bermaydi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();
    await _pump(tester, key);

    expect(key.currentState?.hasSignature, isFalse);
    expect(await tester.runAsync<Uint8List?>(() => key.currentState!.export()), isNull);
  });

  testWidgets('tozalash chizilganini o‘chiradi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();
    await _pump(tester, key);

    final Rect pad = tester.getRect(find.byType(SignaturePad));
    await _draw(tester, pad.center - const Offset(30, 0), pad.center);
    expect(key.currentState?.hasSignature, isTrue);

    key.currentState?.clear();
    await tester.pump();

    expect(key.currentState?.hasSignature, isFalse);
  });

  // Yozuv ketayotganda chizilsa, yuborilgan imzo bilan ekrandagi imzo
  // boshqa-boshqa bo'lib qolardi.
  testWidgets('yozuv ketayotganda chizib bo‘lmaydi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();

    await tester.pumpWidget(
      ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.data,
          home: Scaffold(body: Center(child: SizedBox(height: 200, width: 300, child: SignaturePad(key: key, isLocked: true)))),
        ),
      ),
    );

    final Rect pad = tester.getRect(find.byType(SignaturePad));
    await _draw(tester, pad.center - const Offset(30, 0), pad.center);

    expect(key.currentState?.hasSignature, isFalse);
  });

  // Klaviatura ochilganda maydon kichrayadi, nuqtalar esa to'liq o'lchamdagi
  // koordinatalarda chizilgan. Eksport faqat joriy o'lchamga tayansa,
  // klaviatura ochiq holda yuborilgan imzoning pasti kesilib qolardi.
  testWidgets('maydon kichraysa ham imzo kesilmaydi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();

    await tester.pumpWidget(
      ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    Future<void> pumpWithHeight(double height) => tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.data,
          home: Scaffold(
            body: Center(
              child: SizedBox(height: height, width: 300, child: SignaturePad(key: key, isLocked: false)),
            ),
          ),
        ),
      ),
    );

    await pumpWithHeight(300);

    final Rect pad = tester.getRect(find.byType(SignaturePad));
    // Pastki qismda chiziladi — aynan shu joy kesilardi.
    await _draw(tester, pad.bottomLeft + const Offset(20, -30), pad.bottomRight + const Offset(-20, -20));

    // Klaviatura ochildi.
    await pumpWithHeight(80);

    final Uint8List? png = await tester.runAsync<Uint8List?>(() => key.currentState!.export());
    expect(png, isNotNull);

    final ui.Image? image = await tester.runAsync<ui.Image>(() async {
      final ui.Codec codec = await ui.instantiateImageCodec(png!);
      final ui.FrameInfo frame = await codec.getNextFrame();

      return frame.image;
    });

    expect(image, isNotNull);
    expect(image!.height, greaterThan(200), reason: 'imzoning pasti kesib tashlangan');
    image.dispose();
  });

  // Eng muhim tekshiruv: chiziq **ekranga** tushdimi.
  //
  // `export()` yangi painter bilan chizadi, ya'ni u `shouldRepaint` xato
  // bo'lsa ham ishlaydi — imzo faylga tushadi, lekin foydalanuvchi ekranda
  // hech nima ko'rmaydi. Aynan shu holat bo'lgan edi: nuqtalar ro'yxati
  // joyida o'zgartirilgani uchun `oldDelegate.points` bilan `points` bitta
  // obyekt edi va uzunlik solishtiruvi doim "o'zgarmadi" der edi.
  testWidgets('chiziq ekranga tushadi', (WidgetTester tester) async {
    final GlobalKey<SignaturePadState> key = GlobalKey<SignaturePadState>();
    final GlobalKey boundary = GlobalKey();

    await tester.pumpWidget(
      ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MaterialApp(
          theme: AppTheme.data,
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: boundary,
                child: SizedBox(height: 200, width: 300, child: SignaturePad(key: key, isLocked: false)),
              ),
            ),
          ),
        ),
      ),
    );

    final Rect pad = tester.getRect(find.byType(SignaturePad));

    // Birinchi chiziq: ko'rsatma matni yo'qolgani uchun daraxt baribir
    // o'zgaradi va qayta chiziladi — bu `shouldRepaint` ni sinamaydi.
    await _draw(tester, pad.centerLeft + const Offset(20, -30), pad.centerRight - const Offset(20, 30));
    final int first = await _darkPixels(tester, boundary);

    // Ikkinchi chiziq: daraxt endi o'zgarmaydi, ya'ni ekran faqat
    // `shouldRepaint` tufayli yangilanadi.
    await _draw(tester, pad.centerLeft + const Offset(20, 30), pad.centerRight - const Offset(20, -30));
    final int second = await _darkPixels(tester, boundary);

    expect(key.currentState?.hasSignature, isTrue);
    expect(second, greaterThan(first), reason: 'chizilgan chiziq ekranda ko‘rinmayapti');
  });
}

/// Maydondagi qora piksellar soni. Ko'rsatma matni ham qoramtir bo'lgani
/// uchun mutlaq son emas, **o'sish** tekshiriladi.
Future<int> _darkPixels(WidgetTester tester, GlobalKey boundary) async {
  final int? count = await tester.runAsync<int>(() async {
    final RenderRepaintBoundary render =
        tester.renderObject<RenderRepaintBoundary>(find.byKey(boundary));

    final ui.Image image = await render.toImage();
    final ByteData? data = await image.toByteData();
    image.dispose();

    if (data == null) return 0;

    final Uint8List pixels = data.buffer.asUint8List();
    int dark = 0;

    for (int i = 0; i + 3 < pixels.length; i += 4) {
      final int alpha = pixels[i + 3];
      final int luminance = (pixels[i] + pixels[i + 1] + pixels[i + 2]) ~/ 3;

      if (alpha > 200 && luminance < 100) dark++;
    }

    return dark;
  });

  return count ?? 0;
}