import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/presentation/pages/signature_page.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/participant_signing_tile.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/signature_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Imzo maydoni scroll qiladigan ota-ona ichida turmasligi kerak.
///
/// U ro'yxat ichida turganda vertikal harakat uchun ikkita da'vogar bo'lardi —
/// pad ning `PanGestureRecognizer` i va `ListView` ning vertikal drag'i — va
/// qaysi biri yutishi barmoqning tikligiga bog'liq bo'lib qolardi: bazida
/// chizish o'rniga ro'yxat surilardi. Buni sozlash bilan emas, tuzilma bilan
/// hal qilingan, shuning uchun test ham tuzilmani tekshiradi.
const SigningParticipant _ready = SigningParticipant(
  id: 7,
  isClient: true,
  name: 'Aliyev Vali',
  passport: 'AB1234567',
  birthday: '12.03.1990',
  phone: '',
  isFaceChecked: true,
  signUrl: '',
);

Future<void> _prepare(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(393, 852)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()),
  );
  await AppTheme.init();
  ScreenSize.setSizes();
}

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  ScreenUtilInit(
    designSize: const Size(393, 852),
    builder: (_, _) => MaterialApp(theme: AppTheme.data, home: child),
  ),
);

void main() {
  testWidgets('imzo maydonining scroll qiladigan ota-onasi yo‘q', (WidgetTester tester) async {
    await _prepare(tester);
    await _pump(tester, const SignaturePage(participantName: 'Aliyev Vali'));

    expect(find.byType(SignaturePad), findsOneWidget);
    expect(
      find.ancestor(of: find.byType(SignaturePad), matching: find.byType(Scrollable)),
      findsNothing,
      reason: 'chizish maydoni scroll bilan bir maydonda turmasligi kerak',
    );
  });

  testWidgets('maydon ekranning katta qismini egallaydi', (WidgetTester tester) async {
    await _prepare(tester);
    await _pump(tester, const SignaturePage(participantName: 'Aliyev Vali'));

    // Ilgari u ro'yxat ichidagi 160px lik tasma edi.
    expect(tester.getSize(find.byType(SignaturePad)).height, greaterThan(300));
  });

  // Chizish maydoni ro'yxatga qaytarilsa, to'qnashuv ham qaytadi.
  testWidgets('ishtirokchi qatorida chizish maydoni yo‘q', (WidgetTester tester) async {
    await _prepare(tester);
    await _pump(
      tester,
      Scaffold(
        body: ListView(
          children: <Widget>[
            ParticipantSigningTile(
              participant: _ready,
              role: 'Mijoz',
              isExpanded: true,
              isBusy: false,
              canSign: true,
              canConfirmFace: false,
              reason: '',
              onToggle: () {},
              onFaceCheck: () {},
              onSign: () {},
              onBlocked: () {},
            ),
          ],
        ),
      ),
    );

    expect(find.byType(SignaturePad), findsNothing);
  });
}
