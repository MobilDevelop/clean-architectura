import 'dart:async';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_form.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/contract_write_usecases.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/get_contract_details_usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/create/contract_create_bloc.dart';
import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_income_repository.dart';
import '_fake_repository.dart';

ContractProduct _product() => const ContractProduct(
  id: 1,
  supplier: CatalogItem(id: 1, name: 's'),
  category: CatalogItem(id: 2, name: 'k'),
  brand: CatalogItem(id: 3, name: 'b'),
  variant: CatalogItem(id: 4, name: 'v'),
  price: 100,
  count: 1,
  imeis: <String>[],
);

ContractDetails _details({
  int statusCode = 1,
  int termMonths = 12,
  int paymentDay = 15,
  bool isFormal = true,
  List<ContractProduct> products = const <ContractProduct>[],
  ContractCard card = const ContractCard(id: 0, number: '', phone: '', month: 0, year: 0),
}) => ContractDetails(
  id: 5,
  statusCode: statusCode,
  clientName: 'Mijoz',
  termMonths: termMonths,
  paymentDay: paymentDay,
  isFormal: isFormal,
  hasCarIncome: false,
  fileUrl: '',
  products: products,
  guarantors: const <ContractGuarantor>[],
  card: card,
  tariff: const AppliedTariff(id: 0, name: '', isActive: false),
  benefit: null,
  mibFailReason: '',
  katmFailReason: '',
  workplaceCategoryId: 0,
);

ContractCreateBloc _bloc(
  FakeContractCreateRepository repo,
  FakeContractIncomeRepository income, {
  int? contractId = 5,
  ContractChanges? changes,
}) => ContractCreateBloc(
  args: ContractCreateArgs(clientId: 42, contractId: contractId),
  getDetails: GetContractDetailsUsecase(repo),
  getPaymentDays: GetPaymentDaysUsecase(repo),
  getOccupations: GetOccupationsUsecase(income),
  submit: SubmitContractUsecase(repo),
  changes: changes ?? ContractChanges(),
);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 40));

void main() {
  late FakeContractCreateRepository repo;
  late FakeContractIncomeRepository income;

  setUp(() {
    repo = FakeContractCreateRepository();
    income = FakeContractIncomeRepository();
  });

  test('daromad asosi karta biriktirilgan bo‘lsa o‘zgarmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(
      _details(card: const ContractCard(id: 7, number: '8600', phone: '998', month: 9, year: 30)),
    );
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();
    expect(bloc.state.canChangeBasis, isFalse);

    bloc.add(const BasisChanged(IncomeBasis.informal));
    await _settle();

    expect(bloc.state.form.basis, IncomeBasis.formal);

    await bloc.close();
  });

  test('muddat chegaradan chiqmaydi va to‘lov kuni tanlanadi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();

    bloc.add(const TermChanged(99));
    await _settle();
    expect(bloc.state.form.termMonths, 12);

    bloc.add(const PaymentDaySelected(2));
    await _settle();
    expect(bloc.state.form.paymentDay, 25);

    await bloc.close();
  });

  test('shartnoma yuklanadi, avval tanlangan to‘lov kuni saqlanadi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details(termMonths: 9, paymentDay: 15));
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();

    expect(bloc.state.form.termMonths, 9);
    expect(bloc.state.form.paymentDays, <int>[5, 15, 25]);
    expect(bloc.state.form.paymentDay, 15);

    await bloc.close();
  });

  test('qoralama yo‘q bo‘lsa shartnoma so‘ralmaydi', () async {
    final ContractCreateBloc bloc = _bloc(repo, income, contractId: null);

    bloc.add(const ContractRequested());
    await _settle();

    expect(bloc.state.details, isNull);
    expect(bloc.state.isLoading, isFalse);

    await bloc.close();
  });

  test('tovarsiz yuborishda so‘rov ketmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();
    bloc.add(const SubmitRequested());
    await _settle();

    expect(repo.submitCalls, 0);
    expect(bloc.state.issue, ContractFormIssue.noProducts);

    await bloc.close();
  });

  test('status 1 da POST, boshqa statusda PUT ketadi', () async {
    repo.detailsResult = Ok<ContractDetails>(
      _details(products: <ContractProduct>[_product()]),
    );
    final ContractCreateBloc draft = _bloc(repo, income);

    draft.add(const ContractRequested());
    await _settle();
    draft.add(const SubmitRequested());
    await _settle();

    expect(repo.lastSubmit?.isEdit, isFalse);
    await draft.close();

    // Aynan shu shartnoma tahrirlash uchun qaytadan ochilsa ham, mezon —
    // status, marshrut argumenti emas.
    repo.detailsResult = Ok<ContractDetails>(
      _details(statusCode: 7, products: <ContractProduct>[_product()]),
    );
    final ContractCreateBloc edited = _bloc(repo, income);

    edited.add(const ContractRequested());
    await _settle();
    edited.add(const SubmitRequested());
    await _settle();

    expect(repo.lastSubmit?.isEdit, isTrue);
    await edited.close();
  });

  test('kasb turi so‘ralmagan bo‘lsa yuborilmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(
      _details(products: <ContractProduct>[_product()]),
    );
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();
    bloc.add(const SubmitRequested());
    await _settle();

    expect(repo.lastSubmit?.occupationTypeId, 0);

    await bloc.close();
  });

  test('kasb turi so‘ralgan bo‘lsa u to‘ldirilmaguncha yuborilmaydi', () async {
    income.catalogResult = const Ok<OccupationCatalog>(
      OccupationCatalog(items: <OccupationType>[OccupationType(id: 3, name: 'Ish')], isRequired: true),
    );
    repo.detailsResult = Ok<ContractDetails>(
      _details(isFormal: false, products: <ContractProduct>[_product()]),
    );
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();

    bloc.add(const SubmitRequested());
    await _settle();
    expect(repo.submitCalls, 0);
    expect(bloc.state.issue, ContractFormIssue.occupationMissing);

    bloc.add(const OccupationSelected(OccupationType(id: 3, name: 'Ish')));
    await _settle();
    bloc.add(const SubmitRequested());
    await _settle();

    expect(repo.submitCalls, 1);
    expect(repo.lastSubmit?.occupationTypeId, 3);
    expect(repo.lastSubmit?.isFormal, isFalse);

    await bloc.close();
  });

  test('yuborish ikki marta ketmaydi', () async {
    repo.detailsResult = Ok<ContractDetails>(
      _details(products: <ContractProduct>[_product()]),
    );
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();

    bloc
      ..add(const SubmitRequested())
      ..add(const SubmitRequested());
    await _settle();

    expect(repo.submitCalls, 1);
    expect(bloc.state.isSubmitted, isTrue);

    await bloc.close();
  });

  test('kasb ro‘yxati kelmasa xato ko‘rinadi', () async {
    income.catalogResult = const Err<OccupationCatalog>(NetworkFailure('aloqa'));
    final ContractCreateBloc bloc = _bloc(repo, income);

    bloc.add(const ContractRequested());
    await _settle();

    expect(bloc.state.failure, isA<NetworkFailure>());
    expect(bloc.state.isLoading, isFalse);

    await bloc.close();
  });

  test('tovarlar ekrani qaytargan qoralama id si markazga tushadi', () async {
    repo.detailsResult = Ok<ContractDetails>(_details());
    final ContractCreateBloc bloc = _bloc(repo, income, contractId: null);

    bloc.add(const ContractRequested());
    await _settle();
    expect(bloc.state.contractId, isNull);

    bloc.add(const ContractIdReceived(77));
    await _settle();

    expect(bloc.state.contractId, 77);

    await bloc.close();
  });

  // Shartnoma yuborilgach ro'yxat eskiradi: yangisi uning boshida turadi va
  // foydalanuvchi holatini kuzatadi. Ilgari u tabga o'zi o'tib, ekranni
  // qo'lda yangilardi.
  test('yuborilgach ro‘yxat eskirgani belgilanadi', () async {
    final ContractChanges changes = ContractChanges();
    addTearDown(changes.dispose);

    final List<ContractChange> marks = <ContractChange>[];
    final StreamSubscription<ContractChange> sub = changes.changes.listen(marks.add);
    addTearDown(sub.cancel);

    repo.detailsResult = Ok<ContractDetails>(_details(products: <ContractProduct>[_product()]));

    final ContractCreateBloc bloc = _bloc(repo, income, changes: changes);
    addTearDown(bloc.close);

    bloc.add(const ContractRequested());
    await _settle();

    bloc.add(const SubmitRequested());
    await _settle();

    expect(repo.submitCalls, 1);
    // Qoralama (status 1) birinchi marta yuborildi — ro'yxatga yangi qator.
    expect(marks, <ContractChange>[ContractChange.created]);
  });

  // Yiqilgan yuborishdan keyin ro'yxatda o'zgarish yo'q — behuda so'rov
  // yuborish serverni urardi.
  test('yuborish yiqilsa ro‘yxat eskirmaydi', () async {
    final ContractChanges changes = ContractChanges();
    addTearDown(changes.dispose);

    final List<ContractChange> marks = <ContractChange>[];
    final StreamSubscription<ContractChange> sub = changes.changes.listen(marks.add);
    addTearDown(sub.cancel);

    repo.detailsResult = Ok<ContractDetails>(_details(products: <ContractProduct>[_product()]));
    repo.submitResult = const Err<void>(ServerFailure('xato'));

    final ContractCreateBloc bloc = _bloc(repo, income, changes: changes);
    addTearDown(bloc.close);

    bloc.add(const ContractRequested());
    await _settle();

    bloc.add(const SubmitRequested());
    await _settle();

    expect(marks, isEmpty);
  });
}