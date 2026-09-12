import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/presentation/widgets/invoice_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

Invoice _invoice(ContractStatus status) => Invoice(
  id: 12,
  contractId: 36555548,
  partnerName: 'Ishonch savdo markazi mas\'uliyati cheklangan jamiyati',
  price: 18500000,
  status: status,
  waybillId: 77,
  waybillUrl: 'https://example.test/77.pdf',
);

/// Chegara qo'yilgan matn sig'maganda `didExceedMaxLines` yonadi.
int _ellipsised(WidgetTester tester) {
  int n = 0;

  for (final Element e in find.byType(RichText).evaluate()) {
    final RenderParagraph paragraph = e.renderObject! as RenderParagraph;
    if (paragraph.didExceedMaxLines) n++;
  }

  return n;
}

void main() {
  // Kartada uzun tashkilot nomi ham, uzun holat nomi ham bor. Ikkalasi
  // kesilmasligi kerak — shartnoma kartasidagi bilan bir xil qoida.
  testWidgets('faktura kartasida matn kesilmaydi va toshib ketmaydi', (WidgetTester tester) async {
    addTearDown(tester.view.reset);

    for (final (double width, double scale) in <(double, double)>[(393, 1.0), (360, 1.0), (393, 1.3), (360, 1.3)]) {
      await _one(tester, width, scale);
    }
  });
}

Future<void> _one(WidgetTester tester, double width, double scale) async {
  tester.view
    ..physicalSize = Size(width, 1400)
    ..devicePixelRatio = 1;

  await tester.pumpWidget(ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()));
  await AppTheme.init();
  ScreenSize.setSizes();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (_, _) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale), size: Size(width, 1400)),
        child: MaterialApp(
          theme: AppTheme.data,
          home: Scaffold(
            backgroundColor: AppTheme.colors.backcolor,
            body: ListView(
              children: <Widget>[
                // 11 — «Shartnoma tasdiqlangan», eng uzun holat nomi.
                InvoiceCard(invoice: _invoice(ContractStatus.confirmed), isSending: false, onTap: () {}),
                InvoiceCard(invoice: _invoice(ContractStatus.faceVerified), isSending: true, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  // `pumpAndSettle` emas: yuborish holatidagi aylanish belgisi hech qachon
  // to'xtamaydi va test muddatsiz kutib qolardi.
  await tester.pump();

  expect(tester.takeException(), isNull, reason: '${width.toInt()}px @${scale}x — toshib ketdi');
  expect(_ellipsised(tester), 0, reason: '${width.toInt()}px @${scale}x — matn kesildi');
}
