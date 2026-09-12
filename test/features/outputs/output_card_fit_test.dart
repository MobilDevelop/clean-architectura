import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/presentation/list/output_card.dart';
import 'package:colloborator_v3/features/outputs/presentation/shared/output_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

OutputContract _contract(ContractStatus status) => OutputContract(
  id: 36555548,
  clientId: 1,
  clientName: 'Abdurahmonov Abdulaziz Abdurahmonovich',
  phone: '998901234567',
  totalPrice: 18500000,
  status: status,
  createdAt: '11.09.2026',
  smsSentAt: null,
);

const List<OutputProduct> _products = <OutputProduct>[
  OutputProduct(id: 11, name: 'iPhone 15 Pro Max 256GB Natural Titanium', category: 'Telefonlar', count: 1, price: 18500000),
  OutputProduct(id: 12, name: 'AirPods Pro 2', category: 'Quloqchinlar', count: 2, price: 3200000),
];

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
  // Chiqim kartasi ochilganda tovarlar va amal tugmasi qo'shiladi. Tugma
  // matni tanlangan tovarlar soniga qarab o'sadi («3 ta tovarni qaytarish»),
  // shuning uchun eng uzun holat kichik ekranda va kattalashtirilgan shriftda
  // tekshiriladi.
  testWidgets('ochiq kartada matn kesilmaydi va toshib ketmaydi', (WidgetTester tester) async {
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
                // Imzolangan — chiqim berish tugmasi.
                OutputCard(
                  contract: _contract(ContractStatus.signed),
                  isOpen: true,
                  isLoading: false,
                  products: _products,
                  selected: const <int>{},
                  isReturning: false,
                  onTap: () {},
                  onProductTap: (_) {},
                  onRelease: () {},
                  onReturn: () {},
                ),

                // Tovarsiz imzolangan shartnoma: `for_cancelled` bo'sh
                // ro'yxat qaytarsa ham chiqim tugmasi ko'rinishi shart.
                OutputCard(
                  contract: _contract(ContractStatus.signed),
                  isOpen: true,
                  isLoading: false,
                  products: const <OutputProduct>[],
                  selected: const <int>{},
                  isReturning: false,
                  onTap: () {},
                  onProductTap: (_) {},
                  onRelease: () {},
                  onReturn: () {},
                ),

                // Qolgan holat — qaytarish tugmasi, ikkalasi belgilangan.
                OutputCard(
                  contract: _contract(ContractStatus.invoiceConfirmed),
                  isOpen: true,
                  isLoading: false,
                  products: _products,
                  selected: const <int>{11, 12},
                  isReturning: false,
                  onTap: () {},
                  onProductTap: (_) {},
                  onRelease: () {},
                  onReturn: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  expect(tester.takeException(), isNull, reason: '${width.toInt()}px @${scale}x — toshib ketdi');
  expect(_ellipsised(tester), 0, reason: '${width.toInt()}px @${scale}x — matn kesildi');

  // Tovarsiz shartnomada ham amal tugmasi joyida (uchta karta — uchta tugma).
  expect(find.text(OutputText.release), findsNWidgets(2));
}
