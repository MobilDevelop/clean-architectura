import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/guarantor_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_guarantor_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/usecase/guarantor_usecases.dart';
import 'package:colloborator_v3/features/contract_create/presentation/bloc/contract_guarantors/contract_guarantors_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeRepository implements ContractGuarantorRepository {
  int addedId = 900;
  AddGuarantorParams? added;
  RemoveGuarantorParams? removed;

  @override
  Future<Result<int>> addGuarantor(AddGuarantorParams params) async {
    added = params;

    return Ok<int>(addedId);
  }

  @override
  Future<Result<void>> removeGuarantor(RemoveGuarantorParams params) async {
    removed = params;

    return const Ok<void>(null);
  }
}

ContractGuarantor _guarantor({required int rowId, required int participantId}) => ContractGuarantor(
  rowId: rowId,
  participantId: participantId,
  fullName: 'Karimov Ali',
  passport: 'AA1234567',
  inps: '52909900123456',
  workplaceCategoryId: 4,
  underwriterTypes: const <String>[],
  instrumentTypes: const <String>[],
);

void main() {
  ({ContractGuarantorsBloc bloc, _FakeRepository repository}) build({
    List<ContractGuarantor> guarantors = const <ContractGuarantor>[],
  }) {
    final _FakeRepository repository = _FakeRepository();

    return (
      bloc: ContractGuarantorsBloc(
        contractId: 7,
        clientId: 100,
        guarantors: guarantors,
        addGuarantor: AddGuarantorUsecase(repository),
        removeGuarantor: RemoveGuarantorUsecase(repository),
      ),
      repository: repository,
    );
  }

  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  /// Qator id si (`contract_guarantors.id`) va mijoz id si (`clients.id`)
  /// boshqa-boshqa. Takror tekshiruvi mijoz id si bo'yicha bo'lishi kerak —
  /// aks holda bitta odam ikki marta qo'shiladi.
  test('bir xil mijoz ikki marta qo‘shilmaydi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build(
      guarantors: <ContractGuarantor>[_guarantor(rowId: 21, participantId: 305)],
    );
    addTearDown(t.bloc.close);

    t.bloc.add(
      const GuarantorAdded(
        clientId: 305,
        fullName: 'Karimov Ali',
        passport: 'AA1234567',
        inps: '52909900123456',
        workplaceCategoryId: 4,
      ),
    );
    await settle();

    expect(t.repository.added, isNull);
    expect(t.bloc.state.issue, GuarantorIssue.duplicate);
  });

  test('yangi kafilda mijoz id si tanlovdan, qator id si serverdan olinadi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build();
    addTearDown(t.bloc.close);
    t.repository.addedId = 900;

    t.bloc.add(
      const GuarantorAdded(
        clientId: 305,
        fullName: 'Karimov Ali',
        passport: 'AA1234567',
        inps: '52909900123456',
        workplaceCategoryId: 4,
      ),
    );
    await settle();

    final ContractGuarantor result = t.bloc.state.guarantors.single;

    expect(result.rowId, 900);
    expect(result.participantId, 305);
    expect(t.repository.added?.clientId, 305);
  });

  test('o‘chirish qator id si bilan ketadi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build(
      guarantors: <ContractGuarantor>[_guarantor(rowId: 21, participantId: 305)],
    );
    addTearDown(t.bloc.close);

    t.bloc.add(const GuarantorRemoved(21));
    await settle();

    expect(t.repository.removed?.rowId, 21);
    expect(t.bloc.state.guarantors, isEmpty);
  });

  /// Anderrayter yoki instrument saqlangach shartnoma qayta o'qiladi va
  /// yangi ro'yxat blocga shu event bilan yetib boradi — busiz karta eski
  /// ma'lumotni ko'rsatib turardi.
  test('shartnoma qayta o‘qilganda ro‘yxat yangilanadi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build(
      guarantors: <ContractGuarantor>[_guarantor(rowId: 21, participantId: 305)],
    );
    addTearDown(t.bloc.close);

    t.bloc.add(
      GuarantorsSynced(<ContractGuarantor>[
        ContractGuarantor(
          rowId: 21,
          participantId: 305,
          fullName: 'Karimov Ali',
          passport: 'AA1234567',
          inps: '52909900123456',
          workplaceCategoryId: 4,
          underwriterTypes: const <String>['salary'],
          instrumentTypes: const <String>['p2p'],
        ),
      ]),
    );
    await settle();

    expect(t.bloc.state.guarantors.single.instrumentTypes, <String>['p2p']);
    expect(t.bloc.state.guarantors.single.underwriterTypes, <String>['salary']);
  });

  /// Server javobi kelmasdan eski ro'yxat kelsa, mahalliy o'zgarish bekor
  /// bo'lib qolardi.
  test('yozuv ketayotganda sinxronlanmaydi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build(
      guarantors: <ContractGuarantor>[_guarantor(rowId: 21, participantId: 305)],
    );
    addTearDown(t.bloc.close);

    t.bloc
      ..add(const GuarantorRemoved(21))
      ..add(const GuarantorsSynced(<ContractGuarantor>[]));

    expect(t.bloc.state.guarantors, hasLength(1));
    await settle();
  });

  test('mijozning o‘zi kafil bo‘lmaydi', () async {
    final ({ContractGuarantorsBloc bloc, _FakeRepository repository}) t = build();
    addTearDown(t.bloc.close);

    t.bloc.add(
      const GuarantorAdded(
        clientId: 100,
        fullName: 'Mijoz',
        passport: '',
        inps: '',
        workplaceCategoryId: 0,
      ),
    );
    await settle();

    expect(t.repository.added, isNull);
    expect(t.bloc.state.issue, GuarantorIssue.selfGuarantee);
  });
}
