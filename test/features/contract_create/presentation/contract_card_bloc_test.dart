import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/income.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/income_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/income/contract_card_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fake_income_repository.dart';

const ContractCard _noCard = ContractCard(id: 0, number: '', phone: '', month: 0, year: 0);

ContractCardBloc _bloc(FakeContractIncomeRepository repo, {ContractCard card = _noCard}) => ContractCardBloc(
  contractId: 5,
  clientId: 42,
  card: card,
  addCard: AddCardUsecase(repo),
  removeCard: RemoveCardUsecase(repo),
);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 30));

void _fill(ContractCardBloc bloc) => bloc.add(
  const CardFieldChanged(phone: '998901234567', number: '8600123412341234', expiry: '0930'),
);

void main() {
  late FakeContractIncomeRepository repo;

  setUp(() => repo = FakeContractIncomeRepository());

  test('to‘liq bo‘lmagan karta serverga ketmaydi', () async {
    final ContractCardBloc bloc = _bloc(repo);

    bloc
      ..add(const CardFieldChanged(phone: '99890'))
      ..add(const CardSubmitted());
    await _settle();

    expect(repo.addCardCalls, 0);
    expect(bloc.state.issue, CardFieldIssue.phoneIncomplete);

    await bloc.close();
  });

  test('karta faqat server id bergandan keyin ko‘rinadi', () async {
    repo.addCardResult = const Err<int>(ServerFailure('server'));
    final ContractCardBloc bloc = _bloc(repo);

    _fill(bloc);
    bloc.add(const CardSubmitted());
    await _settle();

    expect(bloc.state.card.isEmpty, isTrue);
    expect(bloc.state.failure, isA<ServerFailure>());
    expect(bloc.state.revision, 0);

    repo.addCardResult = const Ok<int>(7);
    bloc.add(const Retried());
    await _settle();

    expect(bloc.state.card.id, 7);
    expect(bloc.state.revision, 1);
    expect(repo.lastCard?.form.month, 9);

    await bloc.close();
  });

  test('karta o‘chirish xato bersa karta joyida qoladi', () async {
    repo.removeCardResult = const Err<void>(ServerFailure('server'));
    final ContractCardBloc bloc = _bloc(
      repo,
      card: const ContractCard(id: 7, number: '8600', phone: '998', month: 9, year: 30),
    );

    bloc.add(const CardRemoved());
    await _settle();

    expect(repo.removeCardCalls, 1);
    expect(bloc.state.card.id, 7);
    expect(bloc.state.failure, isA<ServerFailure>());

    await bloc.close();
  });

  test('har muvaffaqiyatli yozuv revizyani oshiradi', () async {
    final ContractCardBloc bloc = _bloc(repo);

    _fill(bloc);
    bloc.add(const CardSubmitted());
    await _settle();
    expect(bloc.state.revision, 1);

    bloc.add(const CardRemoved());
    await _settle();

    // Yopishqoq bayroq bo'lganda ikkinchi o'zgarish tinglovchini uyg'otmasdi.
    expect(bloc.state.revision, 2);
    expect(bloc.state.card.isEmpty, isTrue);

    await bloc.close();
  });
}
