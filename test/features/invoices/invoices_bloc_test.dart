import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';
import 'package:colloborator_v3/features/invoices/domain/repositories/invoices_repository.dart';
import 'package:colloborator_v3/features/invoices/domain/usecase/invoices_usecases.dart';
import 'package:colloborator_v3/features/invoices/presentation/bloc/invoices/invoices_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements InvoicesRepository {
  final List<InvoicesQuery> queries = <InvoicesQuery>[];
  final List<int> sent = <int>[];

  /// Sahifa raqami → natija.
  Map<int, Result<InvoicesPageResult>> pages = <int, Result<InvoicesPageResult>>{};
  Result<void> sendResult = const Ok<void>(null);

  @override
  Future<Result<InvoicesPageResult>> getInvoices(InvoicesQuery query) async {
    queries.add(query);

    return pages[query.page] ??
        const Ok<InvoicesPageResult>(InvoicesPageResult(items: <Invoice>[], isLast: true));
  }

  @override
  Future<Result<void>> sendToPartner(int waybillId) async {
    sent.add(waybillId);

    return sendResult;
  }
}

Invoice _invoice(int id, {int waybillId = 0}) => Invoice(
  id: id,
  contractId: id * 100,
  partnerName: 'Ta\'minotchi $id',
  price: 1800000,
  status: ContractStatus.invoiceCreated,
  waybillId: waybillId == 0 ? id * 7 : waybillId,
  waybillUrl: 'https://example.test/$id.pdf',
);

Result<InvoicesPageResult> _page(List<int> ids, {bool isLast = false}) => Ok<InvoicesPageResult>(
  InvoicesPageResult(items: ids.map((int id) => _invoice(id)).toList(), isLast: isLast),
);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeRepository repo;

  InvoicesBloc build() => InvoicesBloc(
    getInvoices: GetInvoicesUsecase(repo),
    send: SendInvoiceUsecase(repo),
  );

  setUp(() => repo = _FakeRepository());

  test('birinchi sahifa o‘qiladi', () async {
    repo.pages = <int, Result<InvoicesPageResult>>{1: _page(<int>[1, 2])};

    final InvoicesBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const InvoicesRequested());
    await _settle();

    expect(bloc.state.invoices.length, 2);
    expect(bloc.state.hasLoaded, isTrue);
    expect(bloc.state.isLoading, isFalse);
  });

  test('keyingi sahifa ro‘yxatga qo‘shiladi', () async {
    repo.pages = <int, Result<InvoicesPageResult>>{
      1: _page(<int>[1, 2]),
      2: _page(<int>[3], isLast: true),
    };

    final InvoicesBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const InvoicesRequested());
    await _settle();

    bloc.add(const NextPageRequested());
    await _settle();

    expect(bloc.state.invoices.map((Invoice e) => e.id), <int>[1, 2, 3]);
    expect(bloc.state.query.page, 2);
    expect(bloc.state.isLast, isTrue);
  });

  // Yiqilgan sahifadan keyin raqam oshsa, o'sha sahifa butunlay tushib
  // qolardi.
  test('sahifa yiqilsa raqam oshmaydi', () async {
    repo.pages = <int, Result<InvoicesPageResult>>{
      1: _page(<int>[1]),
      2: const Err<InvoicesPageResult>(NetworkFailure('aloqa yo‘q')),
    };

    final InvoicesBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const InvoicesRequested());
    await _settle();

    bloc.add(const NextPageRequested());
    await _settle();

    expect(bloc.state.query.page, 1);
    expect(bloc.state.failure, isA<NetworkFailure>());
  });

  test('oxirgi sahifadan keyin so‘rov yuborilmaydi', () async {
    repo.pages = <int, Result<InvoicesPageResult>>{1: _page(<int>[1], isLast: true)};

    final InvoicesBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(const InvoicesRequested());
    await _settle();

    bloc
      ..add(const NextPageRequested())
      ..add(const NextPageRequested());
    await _settle();

    expect(repo.queries.length, 1);
  });

  group('ta’minotchiga yuborish', () {
    test('yuboriladi va xabar bir marta beriladi', () async {
      repo.pages = <int, Result<InvoicesPageResult>>{1: _page(<int>[1])};

      final InvoicesBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const InvoicesRequested());
      await _settle();

      bloc.add(SendRequested(_invoice(1)));
      await _settle();

      expect(repo.sent, <int>[7]);
      expect(bloc.state.sentId, 1);
      expect(bloc.state.sendingId, 0);
    });

    // Manzilda `0` bilan ketgan so'rovni server rad etardi va xodim sababini
    // bilmasdi.
    test('yuk xatisiz so‘rov yuborilmaydi', () async {
      final InvoicesBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(SendRequested(_invoice(1, waybillId: -1).copyWithoutWaybill()));
      await _settle();

      expect(repo.sent, isEmpty);
      expect(bloc.state.failure, isA<ClientFailure>());
    });

    // Yiqilgach «Qayta urinish» ro'yxatni emas, aynan yuborishni takrorlaydi.
    test('qayta urinish aynan yiqilgan amalni takrorlaydi', () async {
      repo.pages = <int, Result<InvoicesPageResult>>{1: _page(<int>[1])};

      final InvoicesBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const InvoicesRequested());
      await _settle();

      final int before = repo.queries.length;

      repo.sendResult = const Err<void>(ServerFailure('xato'));
      bloc.add(SendRequested(_invoice(1)));
      await _settle();
      expect(bloc.state.failure, isA<ServerFailure>());

      repo.sendResult = const Ok<void>(null);
      bloc.add(const Retried());
      await _settle();

      expect(repo.sent.length, 2);
      expect(repo.queries.length, before);
      expect(bloc.state.sentId, 1);
    });
  });

  test('sana tanlanganda ro‘yxat boshidan o‘qiladi', () async {
    repo.pages = <int, Result<InvoicesPageResult>>{1: _page(<int>[1])};

    final InvoicesBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(DateSelected(DateTime(2026, 3, 1)));
    await _settle();

    expect(bloc.state.query.date, DateTime(2026, 3, 1));
    expect(repo.queries.last.page, 1);
  });
}

extension on Invoice {
  /// Yuk xati yozuvi yo'q faktura.
  Invoice copyWithoutWaybill() => Invoice(
    id: id,
    contractId: contractId,
    partnerName: partnerName,
    price: price,
    status: status,
    waybillId: 0,
    waybillUrl: waybillUrl,
  );
}
