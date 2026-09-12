import 'dart:convert';

import 'package:colloborator_v3/core/constants/app_icons.dart';
import 'package:colloborator_v3/core/services/offer_document.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/offer_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Oferta oynasi **birinchi kadrdayoq** matn bilan ochiladi.
///
/// Ikkita yuklanish belgisi bor edi va ikkalasi ham har ochilishda ko'rinardi:
///
/// 1. `HtmlWidget` ning `buildAsync` sukut qiymati `html.length > 10000`, oferta
///    esa ~26 000 belgi. Async rejimda kutubxona `compute()` bilan har safar
///    yangi izolyat ochadi va parse tugagunicha o'zining
///    `CircularProgressIndicator` ini chizadi.
/// 2. Oynaning o'zi `rootBundle.loadString` ni `await` qilardi. `rootBundle`
///    keshlaydi (ikkinchi o'qish 0.3 ms), lekin natija baribir `Future` —
///    ya'ni kamida bitta kadr belgi bilan chiziladi.
///
/// Bu test ikkalasini ham qulflaydi: matn tayyor bo'lganda ekranda birorta
/// yuklanish belgisi bo'lmasligi kerak.
void main() {
  testWidgets('oldindan o‘qilgan oferta yuklanish belgisisiz ochiladi', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (BuildContext context, Widget? child) => const SizedBox.shrink(),
      ),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    final OfferDocument document = OfferDocument(rootBundle);
    await document.warmUp(AppIcons.offerUz);

    // Oldindan o'qish ishlagan bo'lsa matn sinxron olinadi.
    expect(document.ready(AppIcons.offerUz), isNotNull);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (BuildContext context, Widget? child) => Provider<OfferDocument>.value(
          value: document,
          child: MaterialApp(
            theme: AppTheme.data,
            home: Scaffold(body: OfferSheet(onAccepted: () {})),
          ),
        ),
      ),
    );

    // Birorta kadr kutilmaydi: `pumpAndSettle` ham chaqirilmaydi, chunki
    // aylanuvchi belgi bo'lsa u hech qachon tinchimaydi.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CupertinoActivityIndicator), findsNothing);

    // Matn haqiqatan chizilgan.
    expect(find.byType(RichText), findsWidgets);
    expect(find.text('Hujjat ochilmadi'), findsNothing);
  });

  test('hujjat ikkinchi marta o‘qilmaydi', () async {
    final _CountingBundle bundle = _CountingBundle();
    final OfferDocument document = OfferDocument(bundle);

    await document.load(AppIcons.offerUz);
    await document.load(AppIcons.offerUz);

    expect(bundle.reads, 1);
  });
}

final class _CountingBundle extends CachingAssetBundle {
  int reads = 0;

  @override
  Future<ByteData> load(String key) async {
    reads++;

    return ByteData.view(Uint8List.fromList(utf8.encode('<p>oferta</p>')).buffer);
  }
}
