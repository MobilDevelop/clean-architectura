import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/services/push_notifications.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_scoring.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contracts_filter.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/credit_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/katm_report.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/mib_report.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/contracts_usecase.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts/contracts_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contracts/contracts_event.dart';
import 'package:flutter_test/flutter_test.dart';

/// Push kelganda ro'yxat yangilanadi, bosilganda esa shartnoma ochiladi.
///
/// Xabar shakli flex'dan olingan: `message` va `contract_id`
/// (`app_manager_cubit.dart:38`). Flex `contract_id` bo'lganda ro'yxatni
/// yangilardi, bosilganini esa umuman ishlatmasdi — `onMessageOpenedApp`
/// tinglovchisi bo'sh, `getInitialMessage()` esa `if (msg != null) {}`.
final class _FakeContractRepository implements ContractRepository {
  int calls = 0;
  ContractsFilter? lastFilter;
  Result<List<ContractInfo>> result = Ok<List<ContractInfo>>(<ContractInfo>[_contract(7)]);

  @override
  Future<Result<List<ContractInfo>>> getContracts(ContractsFilter filter) async {
    calls++;
    lastFilter = filter;

    return result;
  }

  @override
  Future<Result<List<ContractScoring>>> getScoring(int contractId) async => _unused();
  @override
  Future<Result<List<String>>> getFlexMessages(int contractId) async => _unused();
  @override
  Future<Result<List<CreditParticipant>>> getParticipants(int contractId) async => _unused();
  @override
  Future<Result<MibReport>> getMib(MibParams params) async => _unused();
  @override
  Future<Result<KatmReport>> getKatm(KatmParams params) async => _unused();
  @override
  Future<Result<ContractAuthority>> getAuthority(int contractId) async => _unused();
  @override
  Future<Result<void>> confirmAuthority(int contractId) async => _unused();
  @override
  Future<Result<void>> escalateAuthority(int contractId) async => _unused();
  @override
  Future<Result<void>> allowConfirmation(int contractId) async => _unused();
  @override
  Future<Result<void>> cancelContract(int contractId) async => _unused();

  Result<T> _unused<T>() => Err<T>(const UnknownFailure('test'));
}

ContractInfo _contract(int id) => ContractInfo(
  id: id,
  clientId: 100,
  clientFio: 'Aliyev Vali',
  status: ContractStatus.created,
  birthDay: '',
  passport: '',
  isFormal: true,
  isReturned: false,
  isCard: false,
  flex: false,
  createdAt: '',
  guarantors: const <GuarantorInfo>[],
  clientSignUrl: '',
  isClientFace: false,
  higherPositionConfirmationRequired: false,
  isSentForApproval: false,
  canUserAllowConfirmation: false,
  sentUserFullname: '',
  sentPartnerFullname: '',
  showButtonKATM: false,
  hasBenefit: false,
  engine: AuthorityEngine.legacy,
  statusCode: 1,
);

void main() {
  late _FakeContractRepository repo;
  late PushNotifications push;
  late ContractChanges changes;

  ContractsBloc build() =>
      ContractsBloc(contractsUsecase: ContractsUsecase(repo), push: push, changes: changes);

  setUp(() {
    repo = _FakeContractRepository();
    push = PushNotifications();
    changes = ContractChanges();
  });

  tearDown(() async {
    await push.dispose();
    await changes.dispose();
  });

  test('shartnomali push kelganda ro‘yxat qayta o‘qiladi', () async {
    final ContractsBloc bloc = build();
    addTearDown(bloc.close);

    push.receive(const PushMessage(text: 'Yangi shartnoma', contractId: 7));
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, 1);
  });

  // Har qanday xabarda so'rov yuborish serverni behuda urardi.
  test('shartnomasiz push ro‘yxatni yangilamaydi', () async {
    final ContractsBloc bloc = build();
    addTearDown(bloc.close);

    push.receive(const PushMessage(text: 'Umumiy xabar', contractId: 0));
    await Future<void>.delayed(Duration.zero);

    expect(repo.calls, 0);
  });

  test('bildirishnoma bosilganda sana filtri tozalanadi va shartnoma belgilanadi', () async {
    final ContractsBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(DateSelected(date: DateTime(2026, 3, 1)));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.filter.date, isNotNull);

    push.open(const PushMessage(text: 'Tasdiqlang', contractId: 7));
    await Future<void>.delayed(Duration.zero);

    // Push kelgan shartnoma odatda bugungi emas — filtr uni yashirib qo'yardi.
    expect(bloc.state.filter.date, isNull);
    expect(bloc.state.openContractId, 7);
    expect(repo.lastFilter?.date, isNull);
  });

  // Sovuq startda bildirishnoma bloc yaratilishidan oldin bosiladi va
  // broadcast oqim uni saqlamaydi — `takePending` shuning uchun bor.
  test('bloc yaratilishidan oldin bosilgan xabar yo‘qolmaydi', () async {
    push.open(const PushMessage(text: 'Tasdiqlang', contractId: 7));

    final ContractsBloc bloc = build();
    addTearDown(bloc.close);
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.openContractId, 7);
  });

  test('bir bosish ikki marta ishlamaydi', () async {
    push.open(const PushMessage(text: 'Tasdiqlang', contractId: 7));

    final ContractsBloc bloc = build();
    addTearDown(bloc.close);
    await Future<void>.delayed(Duration.zero);

    bloc.add(const ContractOpened());
    bloc.add(const PushOpened());
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.openContractId, 0);
  });

  group('PushMessage', () {
    // Push maydonlari har doim satr bo'lib keladi.
    test('`contract_id` satrdan o‘qiladi', () {
      final PushMessage message = PushMessage.fromData(const <String, dynamic>{
        'message': 'Shartnoma tasdiqlashga keldi',
        'contract_id': '4821',
      });

      expect(message.contractId, 4821);
      expect(message.text, 'Shartnoma tasdiqlashga keldi');
      expect(message.hasContract, isTrue);
    });

    test('shartnomasiz xabar `0` beradi', () {
      expect(PushMessage.fromData(const <String, dynamic>{}).contractId, 0);
      expect(PushMessage.fromData(const <String, dynamic>{'contract_id': ''}).hasContract, isFalse);
    });

    test('lokal bildirishnoma payloadi borib-kelib saqlanadi', () {
      const PushMessage message = PushMessage(text: 'x', contractId: 12);

      expect(PushMessage.fromPayload(message.payload).contractId, 12);
    });
  });

  group('boshqa ekrandagi yozuv', () {
    // Yangi shartnoma bugungi kun bilan yaratiladi: eski sanaga qo'yilgan
    // filtr uni yashirib qo'yardi, foydalanuvchi esa aynan uni ko'rish uchun
    // bu tabga olib kelinadi.
    test('yangi shartnoma sana filtrini tozalaydi va ro‘yxat qayta o‘qiladi', () async {
      final ContractsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(DateSelected(date: DateTime(2026, 3, 1)));
      await Future<void>.delayed(Duration.zero);

      changes.mark(ContractChange.created);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filter.date, isNull);
      expect(repo.lastFilter?.date, isNull);
    });

    // Tahrirda yangi qator paydo bo'lmaydi — foydalanuvchi qo'ygan filtr
    // o'z joyida qoladi.
    test('tahrir sana filtriga tegmaydi', () async {
      final ContractsBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(DateSelected(date: DateTime(2026, 3, 1)));
      await Future<void>.delayed(Duration.zero);

      final int before = repo.calls;
      changes.mark(ContractChange.updated);
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filter.date, isNotNull);
      expect(repo.calls, before + 1);
    });
  });
}