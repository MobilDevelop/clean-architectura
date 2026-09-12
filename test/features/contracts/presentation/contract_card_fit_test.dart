import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:colloborator_v3/features/contracts/presentation/widgets/contract_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

ContractInfo _c(int status, {List<GuarantorInfo> g = const <GuarantorInfo>[], bool flex = false}) => ContractInfo(
  id: 36555548, clientId: 1, clientFio: 'Abdurahmonov Abdulaziz Abdurahmonovich',
  status: ContractStatus.fromCode(status), birthDay: '', passport: '',
  isFormal: true, isReturned: false, isCard: false, flex: flex,
  createdAt: '11.09.2025', guarantors: g, clientSignUrl: '', isClientFace: false,
  higherPositionConfirmationRequired: false, isSentForApproval: false,
  canUserAllowConfirmation: false, sentUserFullname: '', sentPartnerFullname: '',
  showButtonKATM: false, hasBenefit: false, engine: AuthorityEngine.legacy, statusCode: status,
);

const GuarantorInfo _g = GuarantorInfo(id: 1, name: 'K', inps: '', passport: '', birthday: '', phone: '', isFaceCheck: false, signUrl: '');

/// Shartnoma kartasida hech qanday matn kesilmasligi kerak.
///
/// Nima bo'lgan edi: qatorda yorliq `Expanded` bilan butun bo'sh joyni olardi
/// va uzun status nomi («Shartnoma tasdiqlangan») uch nuqta bilan tugardi —
/// ya'ni xodim shartnomaning holatini o'qiy olmasdi. Endi qator `Wrap`:
/// sig'sa bir qatorda chetlarga tarqaladi, sig'masa qiymat o'z qatoriga
/// tushadi. Mijoz ismi ham kesilmaydi — kesilgan ism mijozni tanishga
/// xalaqit beradi.
///
/// Chegara qo'yilgan matnlar (`maxLines`) sig'maganda `didExceedMaxLines`
/// bayrog'ini yoqadi — test aynan shuni sanaydi.
int _ellipsised(WidgetTester tester) {
  int n = 0;
  for (final Element e in find.byType(RichText).evaluate()) {
    final RenderParagraph p = e.renderObject! as RenderParagraph;
    if (p.didExceedMaxLines) n++;
  }
  return n;
}

void main() {
  testWidgets('kartada birorta matn kesilmaydi', (WidgetTester tester) async {
    addTearDown(tester.view.reset);
    for (final (double w, double sc) in <(double, double)>[(393, 1.0), (360, 1.0), (393, 1.3), (360, 1.3)]) {
      await _one(tester, w, sc);
    }
  });
}

Future<void> _one(WidgetTester tester, double width, double scale) async {
    tester.view..physicalSize = Size(width, 1000)..devicePixelRatio = 1;

    await tester.pumpWidget(ScreenUtilInit(designSize: const Size(393, 852), builder: (_, _) => const SizedBox.shrink()));
    await AppTheme.init();
    ScreenSize.setSizes();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (_, _) => MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale), size: Size(width, 1000)),
          child: MaterialApp(
            theme: AppTheme.data,
            home: Scaffold(
              backgroundColor: AppTheme.colors.backcolor,
              body: ListView(
                padding: EdgeInsets.only(top: ScreenSize.h10),
                children: <Widget>[
                  // 11 — «Shartnoma tasdiqlangan», eng uzun nom.
                  ContractCard(contract: _c(11), pressActions: () {}),
                  ContractCard(contract: _c(24, g: const <GuarantorInfo>[_g, _g], flex: true), pressActions: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      _ellipsised(tester),
      0,
      reason: '${width.toInt()}px @${scale}x da matn kesildi',
    );
}
