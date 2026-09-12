import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/theme/app_theme.dart';
import 'package:colloborator_v3/core/theme/screen_size.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';
import 'package:colloborator_v3/features/customers/domain/usecase/customer_usecase.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers/customers_bloc.dart';
import 'package:colloborator_v3/features/customers/presentation/bloc/customers/customers_event.dart';
import 'package:colloborator_v3/features/customers/presentation/pages/guarantor_picker_page.dart';
import 'package:colloborator_v3/features/customers/presentation/widgets/customer_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kafil tanlash ekranidagi mijoz kartasi mijozlar ekranidagidek keng bo'ladi.
///
/// Karta yon chetini o'zi qo'yadi (`customer_info.dart:74`, `margin: 12`).
/// Ro'yxatga yana yon padding berilsa u ikki marta hisoblanadi: 393px ekranda
/// karta 369 o'rniga 337 bo'lib qolgan, matn esa chetdan 26 emas, 42px da
/// boshlangan edi. Ko'zga "shunchaki havodor" ko'rinadi, lekin ikkita ekran
/// bir xil kartani ikki xil kenglikda chizadi.
final class _FakeCustomerRepository implements CustomerRepository {
  @override
  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams search) async =>
      Ok<List<CustomerInfo>>(<CustomerInfo>[_person()]);

  @override
  Future<Result<CustomerInfo>> checkClient(FaceCheckParams params) async =>
      Err<CustomerInfo>(const UnknownFailure(''));

  @override
  Future<Result<void>> updateCustomer(CustomerUpdateParams params) async => const Ok<void>(null);

  @override
  Future<Result<ScoringInfo>> getScoring(int customerId) async => Err<ScoringInfo>(const UnknownFailure(''));
}

CustomerInfo _person() => const CustomerInfo(
  id: 1,
  fullName: 'Abdurahmonov Abdulaziz Abdurahmonovich',
  inps: '31201000560012',
  passportNumber: 'AB1234567',
  birthDay: '12.03.1990',
  mainAddress: '',
  phones: <PhoneNumber>[PhoneNumber(id: 1, phone: '998901234567', isMain: true, comment: '')],
  passportGiven: '',
  passportExpire: '',
  workplace: WorkplaceInfo(id: 0, name: '', category: WorkplaceCategory(id: 0, name: '')),
  province: Province(id: 0, title: ''),
  region: Region(id: 0, title: ''),
  village: Village(id: 0, title: ''),
  houseNumber: '',
  street: '',
  passportType: true,
);

void main() {
  testWidgets('karta ro‘yxatning yon paddingi bilan torayib qolmaydi', (WidgetTester tester) async {
    const Size screen = Size(393, 852);

    tester.view
      ..physicalSize = screen
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // `ScreenSize` va `AppTheme.data` `.h`/`.sp` ga tayanadi, ular esa
    // `ScreenUtil` sozlangandan keyin hisoblanadi.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: screen,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) => const SizedBox.shrink(),
      ),
    );
    await AppTheme.init();
    ScreenSize.setSizes();

    final CustomersBloc bloc = CustomersBloc(customerUsecase: CustomerUsecase(_FakeCustomerRepository()));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: screen,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, Widget? child) => MaterialApp(
          theme: AppTheme.data,
          home: BlocProvider<CustomersBloc>.value(
            value: bloc,
            child: GuarantorPickerPage(
              verifyOpener: (_, _) async => null,
              newClientOpener: (_) async => null,
              formOpener: (_, _) async => null,
            ),
          ),
        ),
      ),
    );

    bloc
      ..add(const SearchQueryChanged('31201000560012'))
      ..add(const SearchSubmitted());
    await tester.pumpAndSettle();

    final Finder card = find.byType(CustomerInfoWidget).first;

    expect(tester.getSize(card).width, screen.width);
    expect(tester.getTopLeft(card).dx, 0);
  });
}
