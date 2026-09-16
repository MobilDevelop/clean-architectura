import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_instruments.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/guarantor_instruments_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/guarantor_instruments_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/guarantor_instruments/guarantor_instruments_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements GuarantorInstrumentsRepository {
  _FakeRepository(this.server);

  GuarantorInstruments server;
  SaveInstrumentsParams? sent;
  Failure? saveFailure;

  @override
  Future<Result<GuarantorInstruments>> load(GuarantorRef ref) async => Ok<GuarantorInstruments>(server);

  @override
  Future<Result<GuarantorInstruments>> save(SaveInstrumentsParams params) async {
    sent = params;

    final Failure? failure = saveFailure;
    if (failure != null) return Err<GuarantorInstruments>(failure);

    server = GuarantorInstruments(types: params.types, card: server.card, exclusive: server.exclusive, unknown: params.unknown);

    return Ok<GuarantorInstruments>(server);
  }
}

GuarantorInstruments _server({
  Set<InstrumentType> types = const <InstrumentType>{},
  InstrumentCardInfo? card,
  Set<String> unknown = const <String>{},
}) => GuarantorInstruments(
  types: types,
  card: card,
  exclusive: const <Set<InstrumentType>>{
    <InstrumentType>{InstrumentType.informal, InstrumentType.p2p},
  },
  unknown: unknown,
);

void main() {
  const GuarantorRef ref = GuarantorRef(contractId: 7, clientId: 21);

  ({InstrumentsBloc bloc, _FakeRepository repository}) build(GuarantorInstruments server) {
    final _FakeRepository repository = _FakeRepository(server);

    return (
      bloc: InstrumentsBloc(
        ref: ref,
        load: LoadInstrumentsUsecase(repository),
        save: SaveInstrumentsUsecase(repository),
      ),
      repository: repository,
    );
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('serverdagi tanlov o‘qiladi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(types: <InstrumentType>{InstrumentType.car}),
    );
    addTearDown(t.bloc.close);

    t.bloc.add(const InstrumentsStarted());
    await settle();

    expect(t.bloc.state.selected, <InstrumentType>{InstrumentType.car});
    expect(t.bloc.state.isReady, isTrue);
  });

  /// Taqiq backenddan keladi. Xodimga oldindan aytiladi — toast bilan emas,
  /// holat orqali (6.2).
  test('ziddiyatli tur yoqilmaydi va sababi holatga yoziladi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(types: <InstrumentType>{InstrumentType.informal}),
    );
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentToggled(InstrumentType.p2p));
    await settle();

    expect(t.bloc.state.selected, <InstrumentType>{InstrumentType.informal});
    expect(t.bloc.state.conflict, InstrumentType.informal);
  });

  test('p2p yoqilsa karta to‘liq bo‘lmaguncha so‘rov ketmaydi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(_server());
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentToggled(InstrumentType.p2p))
      ..add(const InstrumentsSubmitted());
    await settle();

    expect(t.repository.sent, isNull);
    expect(t.bloc.state.issue, InstrumentIssue.cardNumberShort);
  });

  test('serverda karta bor bo‘lsa qayta kiritish shart emas', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(
        types: <InstrumentType>{InstrumentType.p2p},
        card: const InstrumentCardInfo(mask: '8600 **** **** 1234', expire: '07/30', phone: '998901234567'),
      ),
    );
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentsSubmitted());
    await settle();

    expect(t.repository.sent?.card, isNull);
    expect(t.bloc.state.isSaved, isTrue);
  });

  /// Ilova tanimagan tur `PUT` da tushib qolsa server uni o'chirib yuborardi.
  test('tanilmagan tur so‘rovda qaytariladi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(types: <InstrumentType>{InstrumentType.car}, unknown: <String>{'ipoteka'}),
    );
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentsSubmitted());
    await settle();

    expect(t.repository.sent?.codes, containsAll(<String>['avto', 'ipoteka']));
  });

  test('hammasi o‘chirilsa bo‘sh to‘plam yuboriladi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(types: <InstrumentType>{InstrumentType.car}),
    );
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentToggled(InstrumentType.car))
      ..add(const InstrumentsSubmitted());
    await settle();

    expect(t.repository.sent?.codes, isEmpty);
    expect(t.bloc.state.isSaved, isTrue);
  });

  test('xato bo‘lsa saqlanmadi deb qoladi', () async {
    final ({InstrumentsBloc bloc, _FakeRepository repository}) t = build(
      _server(types: <InstrumentType>{InstrumentType.car}),
    );
    addTearDown(t.bloc.close);
    t.repository.saveFailure = const NetworkFailure('Internet yo‘q');

    t.bloc
      ..add(const InstrumentsStarted())
      ..add(const InstrumentsSubmitted());
    await settle();

    expect(t.bloc.state.isSaved, isFalse);
    expect(t.bloc.state.failure, isA<NetworkFailure>());
  });
}
