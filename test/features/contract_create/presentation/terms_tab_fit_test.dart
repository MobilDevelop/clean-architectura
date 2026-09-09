import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/core/widgets/buttons/main_button.dart';
import 'package:colloborator_v3/core/widgets/headers/page_header.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_summary_card.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_tab_bar.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_terms_tab.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/contract_card_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_income_repository.dart';
import '_fake_repository.dart';

/// «Shartnoma» tabi ekranga sig'adimi — o'lchov bilan javob.
///
/// Bu savol tasodifiy emas: flex'da aynan shu kontent scroll qilmaydigan
/// `Column` da turgan va to'lgan holatda ekrandan toshib ketgan. Ko'zga
/// "sig'ayotganday" ko'rinishi aldamchi — oxirgi qatorlar ekran chetidan
/// sal pastda qoladi.
///
/// 2026-09-08 dagi o'lchov (`maxScrollExtent`, ya'ni toshgan piksel):
///
/// | Holat | Toshish |
/// |---|---|
/// | 393x852, yengil (kartasiz, 3 qo'shimcha) | 82px |
/// | 393x852, to'liq (karta + 5 qo'shimcha) | 242px |
/// | 360x640 (kichik Android) | 319px |
/// | 393x852, tizim shrifti 1.3x | 444px |
///
/// Ya'ni scroll bezak emas — usiz ekran har qanday holatda toshadi.
const ContractCard _card = ContractCard(
  id: 7,
  number: '8600123412341234',
  phone: '998901234567',
  month: 9,
  year: 30,
);

ContractProduct _product(int id) => ContractProduct(
  id: id,
  supplier: const CatalogItem(id: 1, name: 'Idea'),
  category: const CatalogItem(id: 2, name: 'Telefon'),
  brand: const CatalogItem(id: 3, name: 'Apple'),
  variant: const CatalogItem(id: 4, name: 'iPhone 15 Pro Max 256GB'),
  price: 15000000,
  count: 1,
  imeis: const <String>['358240051111110'],
);

/// Eng to'liq holat: karta biriktirilgan, bonus bor, KATM skip ochiq
/// (status 5) — ya'ni «Qo'shimcha» beshala qatori ko'rinadi.
ContractDetails _fullDetails() => ContractDetails(
  id: 12345,
  statusCode: 5,
  clientName: 'Abdurahmonov Abdulaziz Abdurahmonovich',
  termMonths: 12,
  paymentDay: 15,
  isFormal: true,
  hasCarIncome: true,
  fileUrl: '',
  products: <ContractProduct>[_product(1)],
  guarantors: const <ContractGuarantor>[],
  card: _card,
  tariff: const AppliedTariff(id: 0, name: '', isActive: false),
  benefit: const ContractBenefit(
    contractId: 12345,
    requiredAmount: 1000000,
    availableAmount: 5000000,
    usedAmount: 0,
  ),
  mibFailReason: '',
  katmFailReason: '',
  workplaceCategoryId: 4,
);

/// Eng yengil holat: qoralama endi tuzilgan — karta yo'q, bonus yo'q,
/// KATM skip yo'q, ya'ni «Qo'shimcha» da uchta qator turadi.
ContractDetails _leanDetails() => ContractDetails(
  id: 12345,
  statusCode: 1,
  clientName: 'Aliyev Vali',
  termMonths: 12,
  paymentDay: 15,
  isFormal: true,
  hasCarIncome: false,
  fileUrl: '',
  products: <ContractProduct>[_product(1)],
  guarantors: const <ContractGuarantor>[],
  card: const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
  tariff: const AppliedTariff(id: 0, name: '', isActive: false),
  benefit: null,
  mibFailReason: '',
  katmFailReason: '',
  workplaceCategoryId: 4,
);

void main() {

  /// Sahifaning haqiqiy tuzilishi: sarlavha, xulosa kartasi, tab paneli,
  /// tab va pastdagi tugma. Tabga qoladigan balandlik shu tarzda o'lchanadi.
  Future<double> extentOf(
    WidgetTester tester, {
    required Size size,
    double textScale = 1,
    bool isFull = true,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // `ScreenSize` va `AppTheme.data` `.h`/`.sp` ga tayanadi, ular esa
    // `ScreenUtil` sozlangandan keyin hisoblanadi — shuning uchun avval bo'sh
    // daraxt chiziladi.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) => const SizedBox.shrink(),
      ),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    final FakeContractCreateRepository repo = FakeContractCreateRepository()
      ..detailsResult = Ok<ContractDetails>(isFull ? _fullDetails() : _leanDetails());
    final FakeContractIncomeRepository income = FakeContractIncomeRepository();

    final ContractCreateBloc bloc = ContractCreateBloc(
      args: ContractCreateArgs(clientId: 42, contractId: 12345, canSkipKatm: isFull),
      getDetails: GetContractDetailsUsecase(repo),
      getPaymentDays: GetPaymentDaysUsecase(repo),
      getOccupations: GetOccupationsUsecase(income),
      submit: SubmitContractUsecase(repo),
      changes: ContractChanges(),
    )..add(const ContractRequested());

    final ContractCardBloc cardBloc = ContractCardBloc(
      contractId: 12345,
      clientId: 42,
      card: isFull ? _card : const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
      addCard: AddCardUsecase(income),
      removeCard: RemoveCardUsecase(income),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.data,
        home: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
            padding: const EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: MultiBlocProvider(
            providers: <BlocProvider<dynamic>>[
              BlocProvider<ContractCreateBloc>.value(value: bloc),
              BlocProvider<ContractCardBloc>.value(value: cardBloc),
            ],
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                backgroundColor: AppTheme.colors.backcolor,
                body: Column(
                  children: <Widget>[
                    PageHeader(title: "Shartnoma tuzish", topInset: 47, backPress: () {}),

                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ScreenSize.h16,
                        ScreenSize.h12,
                        ScreenSize.h16,
                        ScreenSize.h12,
                      ),
                      child: const ContractSummaryCard(
                        clientName: 'Abdurahmonov Abdulaziz Abdurahmonovich',
                        contractNumber: '12345',
                        statusLabel: 'Skoringda',
                        statusColor: Colors.orange,
                      ),
                    ),

                    const ContractTabBar(productCount: 1, guarantorCount: 0),

                    Expanded(
                      child: BlocBuilder<ContractCreateBloc, ContractCreateState>(
                        builder: (BuildContext context, ContractCreateState state) =>
                            ContractTermsTab(state: state, extraPressed: (_) {}),
                      ),
                    ),

                    SafeArea(
                      top: false,
                      child: MainButton(
                        text: "Yuborish",
                        margin: EdgeInsets.symmetric(
                          horizontal: ScreenSize.h16,
                          vertical: ScreenSize.h8,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 60));
    await tester.pump(const Duration(milliseconds: 400));

    final double extent = tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .maxScrollExtent;

    return extent;
  }

  // Eng yengil holat ham sig'maydi: qoralama endi tuzilgan, karta yo'q,
  // «Qo'shimcha» da atigi uchta qator turibdi — shunda ham 82px toshadi.
  testWidgets('393x852, yengil holat', timeout: const Timeout(Duration(seconds: 30)), (
    WidgetTester tester,
  ) async {
    final double extent = await extentOf(tester, size: const Size(393, 852), isFull: false);

    debugPrint('393x852 yengil => maxScrollExtent = $extent');
    expect(extent, greaterThan(0));
  });

  // To'la holatda esa ikki barobar ko'p toshadi. Aynan shuning uchun scroll
  // olib tashlanmaydi: `Column` bo'lsa flex'dagi toshish qaytadi.
  testWidgets('393x852 — dizayn o‘lchami, eng to‘liq holat', timeout: const Timeout(Duration(seconds: 30)), (WidgetTester tester) async {
    final double extent = await extentOf(tester, size: const Size(393, 852));

    debugPrint('393x852 to‘liq => maxScrollExtent = $extent');
    expect(extent, greaterThan(0));
  });

  testWidgets('360x640 — kichik ekran', timeout: const Timeout(Duration(seconds: 30)), (WidgetTester tester) async {
    final double extent = await extentOf(tester, size: const Size(360, 640));

    debugPrint('360x640 => maxScrollExtent = $extent');
    expect(extent, greaterThan(0));
  });

  testWidgets('393x852, shrift 1.3x — tizim kattalashtirilgan', timeout: const Timeout(Duration(seconds: 30)), (WidgetTester tester) async {
    final double extent = await extentOf(tester, size: const Size(393, 852), textScale: 1.3);

    debugPrint('393x852 @1.3 => maxScrollExtent = $extent');
    expect(extent, greaterThan(0));
  });
}
