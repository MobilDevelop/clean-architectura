import 'dart:io';

import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_release.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/icloud_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/repositories/output_release_repository.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/icloud_usecases.dart';
import 'package:colloborator_v3/features/outputs/domain/usecase/release_usecases.dart';
import 'package:colloborator_v3/features/outputs/presentation/release/release_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeIcloudRepository implements IcloudRepository {
  int calls = 0;
  Result<IcloudRequirements> requirements = const Ok<IcloudRequirements>(
    IcloudRequirements(contractId: 1, isSatisfied: true, devices: <IcloudDevice>[]),
  );

  @override
  Future<Result<IcloudRequirements>> getRequirements(int contractId) async {
    calls++;

    return requirements;
  }

  @override
  Future<Result<void>> saveCredential(IcloudCredential credential) async => const Ok<void>(null);
}

final class _FakeReleaseRepository implements OutputReleaseRepository {
  final List<ReleaseParams> sent = <ReleaseParams>[];
  Result<void> result = const Ok<void>(null);

  @override
  Future<Result<void>> confirmRelease(ReleaseParams params) async {
    sent.add(params);

    return result;
  }

  @override
  Future<Result<void>> returnProducts(ProductReturnParams params) async => const Ok<void>(null);
}

const OutputContract _contract = OutputContract(
  id: 7,
  clientId: 70,
  clientName: 'Mijoz',
  phone: '998901234567',
  totalPrice: 1,
  status: ContractStatus.signed,
  createdAt: '09.09.2026',
  smsSentAt: null,
);

IcloudDevice _device({int? missing}) =>
    IcloudDevice(contractProductId: 1, productId: 2, name: 'iPhone', fullName: '', imei: '', imei2: '', missing: missing);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _FakeIcloudRepository icloud;
  late _FakeReleaseRepository release;
  late ContractChanges changes;
  late List<ContractChange> marks;

  ReleaseBloc build() => ReleaseBloc(
    contract: _contract,
    getRequirements: GetIcloudRequirementsUsecase(icloud),
    confirmRelease: ConfirmReleaseUsecase(release),
    changes: changes,
  );

  setUp(() {
    icloud = _FakeIcloudRepository();
    release = _FakeReleaseRepository();
    changes = ContractChanges();
    marks = <ContractChange>[];
    changes.changes.listen(marks.add);
    addTearDown(changes.dispose);
  });

  // Surat faylining o'zi o'qilmaydi: yo'l `MultipartFile` ga data qatlamida
  // beriladi, bloc esa faqat bor-yo'qligini biladi.
  final File photo = File('test_photo.jpg');

  group('talablar', () {
    test('bajarilgan bo‘lsa forma ochiladi', () async {
      final ReleaseBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const ReleaseStarted());
      await _settle();

      expect(bloc.state.isReady, isTrue);
      expect(bloc.state.isChecking, isFalse);
    });

    test('bajarilmagan bo‘lsa forma ochilmaydi', () async {
      icloud.requirements = Ok<IcloudRequirements>(
        IcloudRequirements(
          contractId: 7,
          isSatisfied: false,
          devices: <IcloudDevice>[_device(), _device(missing: 0)],
        ),
      );

      final ReleaseBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const ReleaseStarted());
      await _settle();

      expect(bloc.state.isReady, isFalse);
      // To'ldirilgan qurilma qolganlar qatoriga qo'shilmaydi.
      expect(bloc.state.pendingDevices, 1);
    });

    // O'qilmagan talabni «bajarilgan» deb hisoblash tekshiruvni jimgina
    // o'chirib qo'yardi (5.8).
    test('o‘qilmasa forma ochilmaydi', () async {
      icloud.requirements = const Err<IcloudRequirements>(ServerFailure('xato'));

      final ReleaseBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const ReleaseStarted());
      await _settle();

      expect(bloc.state.isReady, isFalse);
      expect(bloc.state.failure, isA<ServerFailure>());
    });

  });

  group('tasdiqlash', () {
    Future<ReleaseBloc> ready() async {
      final ReleaseBloc bloc = build();
      addTearDown(bloc.close);

      bloc.add(const ReleaseStarted());
      await _settle();

      return bloc;
    }

    test('suratsiz yuborilmaydi', () async {
      final ReleaseBloc bloc = await ready();

      bloc.add(const CodeChanged('12345'));
      await _settle();
      bloc.add(const ReleaseSubmitted());
      await _settle();

      expect(release.sent, isEmpty);
      expect(bloc.state.issue, ReleaseIssue.photoMissing);
    });

    test('kod to‘liq bo‘lmasa yuborilmaydi', () async {
      final ReleaseBloc bloc = await ready();

      bloc.add(PhotoTaken(photo));
      await _settle();
      bloc.add(const CodeChanged('123'));
      await _settle();
      bloc.add(const ReleaseSubmitted());
      await _settle();

      expect(release.sent, isEmpty);
      expect(bloc.state.issue, ReleaseIssue.codeIncomplete);
    });

    test('to‘ldirilgach yuboriladi', () async {
      final ReleaseBloc bloc = await ready();

      bloc.add(PhotoTaken(photo));
      await _settle();
      bloc.add(const CodeChanged('12345'));
      await _settle();
      bloc.add(const ReleaseSubmitted());
      await _settle();

      expect(release.sent.single.contractId, 7);
      expect(release.sent.single.clientId, 70);
      expect(release.sent.single.code, '12345');
      expect(bloc.state.isDone, isTrue);
      // Chiqim shartnoma holatini o'zgartiradi — shartnomalar ro'yxati
      // xabardor qilinadi.
      expect(marks, <ContractChange>[ContractChange.updated]);
    });

    // Talab bajarilmagan holatda tugma chizilmaydi, lekin holat ekran
    // chizilgandan keyin ham o'zgarishi mumkin.
    test('talab bajarilmagan bo‘lsa yuborilmaydi', () async {
      icloud.requirements = Ok<IcloudRequirements>(
        IcloudRequirements(contractId: 7, isSatisfied: false, devices: <IcloudDevice>[_device()]),
      );

      final ReleaseBloc bloc = await ready();

      bloc.add(PhotoTaken(photo));
      await _settle();
      bloc.add(const CodeChanged('12345'));
      await _settle();
      bloc.add(const ReleaseSubmitted());
      await _settle();

      expect(release.sent, isEmpty);
    });

    // Talab tekshiruvidan keyin tasdiqni yuborish xodim so'ramagan so'rov
    // bo'lardi, va aksincha.
    test('qayta urinish aynan yiqilgan amalni takrorlaydi', () async {
      final ReleaseBloc bloc = await ready();

      bloc.add(PhotoTaken(photo));
      await _settle();
      bloc.add(const CodeChanged('12345'));
      await _settle();

      release.result = const Err<void>(ServerFailure('xato'));
      bloc.add(const ReleaseSubmitted());
      await _settle();
      expect(bloc.state.failure, isA<ServerFailure>());

      release.result = const Ok<void>(null);
      bloc.add(const Retried());
      await _settle();

      expect(release.sent.length, 2);
      // Talablar qayta so'ralmadi: yiqilgani tasdiq edi.
      expect(icloud.calls, 1);
      expect(bloc.state.isDone, isTrue);
    });
  });
}
