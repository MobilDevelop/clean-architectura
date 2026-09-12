import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/output_release_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/outputs_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/outputs_usecases.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/release_usecases.dart';
import 'package:colloborator_v3/features/outputs/presentation/bloc/outputs/outputs_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeReleaseRepository implements OutputReleaseRepository {
  final List<ProductReturnParams> returns = <ProductReturnParams>[];
  Result<void> result = const Ok<void>(null);

  @override
  Future<Result<void>> confirmRelease(ReleaseParams params) async => result;

  @override
  Future<Result<void>> returnProducts(ProductReturnParams params) async {
    returns.add(params);

    return result;
  }
}

final class _FakeRepository implements OutputsRepository {
  final List<OutputsQuery> queries = <OutputsQuery>[];
  int productCalls = 0;

  /// Sahifa raqami → natija.
  Map<int, Result<OutputsPageResult>> pages = <int, Result<OutputsPageResult>>{};
  Result<List<OutputProduct>> products = const Ok<List<OutputProduct>>(<OutputProduct>[]);

  @override
  Future<Result<OutputsPageResult>> getContracts(OutputsQuery query) async {
    queries.add(query);

    return pages[query.page] ??
        const Ok<OutputsPageResult>(OutputsPageResult(items: <OutputContract>[], isLast: true));
  }

  @override
  Future<Result<List<OutputProduct>>> getProducts(int contractId) async {
    productCalls++;

    return products;
  }
}

OutputContract _contract(int id, {ContractStatus status = ContractStatus.confirmed}) => OutputContract(
  id: id,
  clientId: id * 10,
  clientName: 'Mijoz $id',
  phone: '998901234567',
  totalPrice: 5000000,
  status: status,
  createdAt: '09.09.2026',
  smsSentAt: null,
);

Result<OutputsPageResult> _page(List<int> ids, {bool isLast = false}) => Ok<OutputsPageResult>(
  OutputsPageResult(items: ids.map(_contract).toList(), isLast: isLast),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeRepository repo;
  late _FakeReleaseRepository release;
  late ContractChanges changes;
  late List<ContractChange> marks;

  OutputsBloc build() => OutputsBloc(
    getContracts: GetOutputContractsUsecase(repo),
    getProducts: GetOutputProductsUsecase(repo),
    returnProducts: ReturnProductsUsecase(release),
    changes: changes,
  );

  setUp(() {
    repo = _FakeRepository();
    release = _FakeReleaseRepository();
    changes = ContractChanges();
    marks = <ContractChange>[];
    changes.changes.listen(marks.add);
    addTearDown(changes.dispose);
  });

  test('birinchi sahifa o‘qiladi', () async {
    repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[1, 2])};

    final OutputsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const OutputsRequested());
    await _settle();

    expect(bloc.state.contracts.length, 2);
    expect(bloc.state.hasLoaded, isTrue);
    expect(bloc.state.isLoading, isFalse);
  });

  test('keyingi sahifa ro‘yxatga qo‘shiladi', () async {
    repo.pages = <int, Result<OutputsPageResult>>{
      1: _page(<int>[1, 2]),
      2: _page(<int>[3], isLast: true),
    };

    final OutputsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const OutputsRequested());
    await _settle();

    bloc.add(const NextPageRequested());
    await _settle();

    expect(bloc.state.contracts.map((OutputContract e) => e.id), <int>[1, 2, 3]);
    expect(bloc.state.query.page, 2);
    expect(bloc.state.isLast, isTrue);
  });

  // Flex bo'sh javob kelguncha sahifani oshiraverardi — har doim bitta
  // ortiqcha so'rov ketardi.
  test('oxirgi sahifadan keyin so‘rov yuborilmaydi', () async {
    repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[1], isLast: true)};

    final OutputsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const OutputsRequested());
    await _settle();

    bloc
      ..add(const NextPageRequested())
      ..add(const NextPageRequested());
    await _settle();

    expect(repo.queries.length, 1);
  });

  // Yiqilgan sahifadan keyin raqam oshsa, o'sha sahifa butunlay tushib
  // qolardi.
  test('sahifa yiqilsa raqam oshmaydi', () async {
    repo.pages = <int, Result<OutputsPageResult>>{
      1: _page(<int>[1, 2]),
      2: const Err<OutputsPageResult>(NetworkFailure('aloqa yo‘q')),
    };

    final OutputsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const OutputsRequested());
    await _settle();

    bloc.add(const NextPageRequested());
    await _settle();

    expect(bloc.state.query.page, 1);
    expect(bloc.state.contracts.length, 2);
    expect(bloc.state.failure, isA<NetworkFailure>());
  });

  group('tovarlar', () {
    test('qator ochilganda bir marta o‘qiladi', () async {
      repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[7])};
      repo.products = const Ok<List<OutputProduct>>(<OutputProduct>[
        OutputProduct(id: 1, name: 'iPhone', category: 'Telefon', count: 1, price: 15000000),
      ]);

      final OutputsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const OutputsRequested());
      await _settle();

      bloc.add(const ContractToggled(7));
      await _settle();
      expect(bloc.state.products[7]?.length, 1);

      // Yopib qayta ochilganda so'rov takrorlanmaydi.
      bloc.add(const ContractToggled(7));
      await _settle();
      bloc.add(const ContractToggled(7));
      await _settle();

      expect(repo.productCalls, 1);
    });

    // Ochiq turgan bo'sh qator "tovar yo'q" degan ma'noni berardi (5.8).
    test('tovarlar yiqilsa qator yopiladi va xato ko‘rinadi', () async {
      repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[7])};
      repo.products = const Err<List<OutputProduct>>(ServerFailure('xato'));

      final OutputsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const OutputsRequested());
      await _settle();

      bloc.add(const ContractToggled(7));
      await _settle();

      expect(bloc.state.openId, 0);
      expect(bloc.state.failure, isA<ServerFailure>());
    });

    // Ro'yxat yangilangach eski tovarlar boshqa shartnomalarga tegishli
    // bo'lishi mumkin.
    test('yangilashda ochiq qator va tovarlar tozalanadi', () async {
      repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[7])};
      repo.products = const Ok<List<OutputProduct>>(<OutputProduct>[
        OutputProduct(id: 1, name: 'x', category: '', count: 1, price: 1),
      ]);

      final OutputsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const OutputsRequested());
      await _settle();
      bloc.add(const ContractToggled(7));
      await _settle();
      expect(bloc.state.products, isNotEmpty);

      bloc.add(const OutputsRequested());
      await _settle();

      expect(bloc.state.openId, 0);
      expect(bloc.state.products, isEmpty);
    });
  });


  group('qaytarish', () {
    Future<OutputsBloc> opened() async {
      repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[7])};
      repo.products = const Ok<List<OutputProduct>>(<OutputProduct>[
        OutputProduct(id: 11, name: 'iPhone', category: 'Telefon', count: 1, price: 1),
        OutputProduct(id: 12, name: 'AirPods', category: 'Quloqchin', count: 1, price: 1),
      ]);

      final OutputsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const OutputsRequested());
      await _settle();
      bloc.add(const ContractToggled(7));
      await _settle();

      return bloc;
    }

    test('belgilash qo‘shiladi va olinadi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();
      expect(bloc.state.selected, <int>{11});

      bloc.add(const ProductToggled(12));
      await _settle();
      expect(bloc.state.selected, <int>{11, 12});

      bloc.add(const ProductToggled(11));
      await _settle();
      expect(bloc.state.selected, <int>{12});
    });

    // Belgilar ochiq shartnomaga tegishli: qator almashganda ular qolsa,
    // boshqa shartnomaning tovarlari qaytarilib ketardi.
    test('boshqa qator ochilganda belgilar tozalanadi', () async {
      repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[7, 8])};
      repo.products = const Ok<List<OutputProduct>>(<OutputProduct>[
        OutputProduct(id: 11, name: 'x', category: '', count: 1, price: 1),
      ]);

      final OutputsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const OutputsRequested());
      await _settle();
      bloc.add(const ContractToggled(7));
      await _settle();
      bloc.add(const ProductToggled(11));
      await _settle();
      expect(bloc.state.selected, isNotEmpty);

      bloc.add(const ContractToggled(8));
      await _settle();

      expect(bloc.state.selected, isEmpty);
    });

    // Bo'sh so'rov shartnomani o'zgartirmaydi, lekin javobi muvaffaqiyat
    // bo'lgani uchun ekran «qaytarildi» deb ko'rsatardi (5.8).
    test('tanlanmagan holda so‘rov yuborilmaydi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ReturnRequested());
      await _settle();

      expect(release.returns, isEmpty);
      expect(bloc.state.isReturned, isFalse);
      expect(bloc.state.failure, isA<ClientFailure>());
    });

    test('qaytarilgach ro‘yxat yangilanadi va belgilar tozalanadi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();

      final int before = repo.queries.length;

      bloc.add(const ReturnRequested());
      await _settle();

      expect(release.returns.single.contractId, 7);
      expect(release.returns.single.productIds, <int>[11]);
      expect(bloc.state.selected, isEmpty);
      expect(repo.queries.length, before + 1);
    });

    // Qaytarish shartnoma holatini o'zgartiradi: shartnomalar ro'yxati
    // xabardor qilinmasa, u eski holatni ko'rsatib turardi (5.8).
    test('qaytarilgach shartnomalar ro‘yxati xabardor qilinadi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();
      bloc.add(const ReturnRequested());
      await _settle();

      expect(marks, <ContractChange>[ContractChange.updated]);
    });

    // Banner qator yopilganda ham ekranda qolib, «Qayta urinish» hech nima
    // qilmasdi: `_returnRequested` ochiq qator yo'qligi uchun darhol qaytardi.
    test('qator yopilganda xato ham tozalanadi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();

      release.result = const Err<void>(ServerFailure('xato'));
      bloc.add(const ReturnRequested());
      await _settle();
      expect(bloc.state.failure, isNotNull);

      // Xodim kartani bosib qatorni yopadi.
      bloc.add(const ContractToggled(7));
      await _settle();

      expect(bloc.state.failure, isNull);
      expect(bloc.state.openId, 0);
    });

    // Takrorlab bo'lmaydigan holat jimgina o'tib ketmasligi kerak.
    test('qator yopiq bo‘lsa qayta urinish sababini aytadi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();

      release.result = const Err<void>(ServerFailure('xato'));
      bloc.add(const ReturnRequested());
      await _settle();

      final int sent = release.returns.length;

      bloc.add(const ContractToggled(7));
      await _settle();
      bloc.add(const Retried());
      await _settle();

      expect(release.returns.length, sent, reason: 'so‘rov takrorlanmasligi kerak');
      expect(bloc.state.failure, isA<ClientFailure>());
    });

    // Yiqilganda tanlov joyida qolsa «Qayta urinish» xodimdan tanlovni
    // qaytadan so'ramaydi.
    test('yiqilsa belgilar qoladi va qayta urinish o‘sha amalni takrorlaydi', () async {
      final OutputsBloc bloc = await opened();

      bloc.add(const ProductToggled(11));
      await _settle();

      release.result = const Err<void>(ServerFailure('xato'));
      bloc.add(const ReturnRequested());
      await _settle();

      expect(bloc.state.selected, <int>{11});
      expect(bloc.state.failure, isA<ServerFailure>());

      release.result = const Ok<void>(null);
      bloc.add(const Retried());
      await _settle();

      expect(release.returns.length, 2);
      expect(bloc.state.isReturned, isTrue);
    });
  });

  test('sana tanlanganda ro‘yxat boshidan o‘qiladi', () async {
    repo.pages = <int, Result<OutputsPageResult>>{1: _page(<int>[1])};

    final OutputsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(DateSelected(DateTime(2026, 3, 1)));
    await _settle();

    expect(bloc.state.query.date, DateTime(2026, 3, 1));
    expect(repo.queries.last.page, 1);
  });
}
