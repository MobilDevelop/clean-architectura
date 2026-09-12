import 'dart:io';
import 'dart:typed_data';

import 'package:colloborator_v3/core/contract/contract_changes.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contract_signing_repository.dart';
import 'package:colloborator_v3/features/contracts/domain/usecase/signing_usecases.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_bloc.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_event.dart';
import 'package:colloborator_v3/features/contracts/presentation/bloc/contract_signing_state.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FakeSigningRepository implements ContractSigningRepository {
  int fileCalls = 0;
  int faceCalls = 0;
  int signCalls = 0;

  Result<String> fileResult = const Ok<String>('<p>shartnoma</p>');
  Result<void> faceResult = const Ok<void>(null);
  Result<SignatureResult> signResult = const Ok<SignatureResult>(
    SignatureResult(signUrl: 'https://s3/sign.png', isContractSigned: false),
  );

  @override
  Future<Result<String>> getContractFile(ContractFileParams params) async {
    fileCalls++;

    return fileResult;
  }

  @override
  Future<Result<void>> confirmFace(FaceConfirmParams params) async {
    faceCalls++;

    return faceResult;
  }

  @override
  Future<Result<SignatureResult>> sign(SignatureParams params) async {
    signCalls++;

    return signResult;
  }
}

const SigningParticipant _client = SigningParticipant(
  id: 7,
  isClient: true,
  name: 'Aliyev Vali',
  passport: 'AB1234567',
  birthday: '12.03.1990',
  phone: '',
  isFaceChecked: false,
  signUrl: '',
);

const SigningParticipant _guarantor = SigningParticipant(
  id: 21,
  isClient: false,
  name: 'Kafil',
  passport: 'CD7654321',
  birthday: '01.01.1985',
  phone: '998901234567',
  isFaceChecked: true,
  signUrl: '',
);

ContractSigning _signing({List<SigningParticipant> participants = const <SigningParticipant>[_client, _guarantor]}) =>
    ContractSigning(contractId: 55, isFlex: false, participants: participants);

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  late _FakeSigningRepository repo;
  late ContractChanges changes;

  ContractSigningBloc build({ContractSigning? signing}) => ContractSigningBloc(
    signing: signing ?? _signing(),
    getFile: GetContractFileUsecase(repo),
    confirmFace: ConfirmParticipantFaceUsecase(repo),
    sign: SignContractUsecase(repo),
    changes: changes,
  );

  setUp(() {
    repo = _FakeSigningRepository();
    changes = ContractChanges();
  });

  tearDown(() => changes.dispose());

  test('yuz tasdig‘i faqat o‘sha ishtirokchiga yoziladi', () async {
    final ContractSigningBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(FaceCaptured(participantId: 7, photo: File('face.jpg')));
    await _settle();

    expect(bloc.state.signing.participantOf(7)?.isFaceChecked, isTrue);
    // Kafilning holati tegilmagan — flex'da bu ikkita alohida tarmoq edi.
    expect(bloc.state.signing.participantOf(21)?.isFaceChecked, isTrue);
    expect(bloc.state.signing.participantOf(21)?.isSigned, isFalse);
  });

  // Mahalliy holat faqat `Ok` dan keyin o'zgaradi: aks holda ekran serverda
  // bo'lmagan narsani ko'rsatib turardi (5.8).
  test('yuz tasdig‘i yiqilsa holat o‘zgarmaydi', () async {
    repo.faceResult = const Err<void>(ServerFailure('xato'));

    final ContractSigningBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(FaceCaptured(participantId: 7, photo: File('face.jpg')));
    await _settle();

    expect(bloc.state.signing.participantOf(7)?.isFaceChecked, isFalse);
    expect(bloc.state.failure, isA<ServerFailure>());
  });

  test('oxirgi imzo shartnomani yakunlaydi', () async {
    final ContractSigningBloc bloc = build(
      signing: _signing(
        participants: <SigningParticipant>[
          _client.copyWith(isFaceChecked: true, signUrl: 'https://s3/a.png'),
          _guarantor,
        ],
      ),
    );
    addTearDown(bloc.close);

    bloc.add(SignatureSubmitted(participantId: 21, signature: Uint8List.fromList(<int>[1, 2, 3]), comment: ''));
    await _settle();

    expect(bloc.state.signing.isAllSigned, isTrue);
    expect(bloc.state.isFinished, isTrue);
  });

  // Server 201 ni har doim qaytarishi tasdiqlanmagan, shuning uchun ekran
  // o'zi ham hisoblaydi — lekin oraliq imzo yakun deb qabul qilinmasligi kerak.
  test('oraliq imzo shartnomani yakunlamaydi', () async {
    final ContractSigningBloc bloc = build(
      signing: _signing(participants: <SigningParticipant>[_client.copyWith(isFaceChecked: true), _guarantor]),
    );
    addTearDown(bloc.close);

    bloc.add(SignatureSubmitted(participantId: 7, signature: Uint8List.fromList(<int>[1]), comment: ''));
    await _settle();

    expect(bloc.state.signing.signedCount, 1);
    expect(bloc.state.isFinished, isFalse);
  });

  // «Qayta urinish» aynan yiqilgan amalni takrorlaydi: yuz xatosidan keyin
  // imzo yuborilsa, foydalanuvchi so'ramagan yozuv ketardi.
  test('«Qayta urinish» yiqilgan yuz tasdig‘ini takrorlaydi, imzoni emas', () async {
    repo.faceResult = const Err<void>(ServerFailure('xato'));

    final ContractSigningBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(FaceCaptured(participantId: 7, photo: File('face.jpg')));
    await _settle();

    bloc.add(const Retried());
    await _settle();

    expect(repo.faceCalls, 2);
    expect(repo.signCalls, 0);
  });

  test('yuzi tasdiqlanmagan ishtirokchi uchun so‘rov ketmaydi', () async {
    final ContractSigningBloc bloc = build();
    addTearDown(bloc.close);

    bloc.add(SignatureSubmitted(participantId: 7, signature: Uint8List.fromList(<int>[1]), comment: ''));
    await _settle();

    expect(repo.signCalls, 0);
    expect(bloc.state.failure, isA<ClientFailure>());
  });

  test('bo‘sh imzo yuborilmaydi', () async {
    final ContractSigningBloc bloc = build(
      signing: _signing(participants: <SigningParticipant>[_client.copyWith(isFaceChecked: true)]),
    );
    addTearDown(bloc.close);

    bloc.add(SignatureSubmitted(participantId: 7, signature: Uint8List(0), comment: ''));
    await _settle();

    expect(repo.signCalls, 0);
  });

  test('imzo qo‘yilgach ro‘yxat eskirgani belgilanadi', () async {
    final List<ContractChange> marks = <ContractChange>[];
    changes.changes.listen(marks.add);

    final ContractSigningBloc bloc = build(
      signing: _signing(participants: <SigningParticipant>[_client.copyWith(isFaceChecked: true), _guarantor]),
    );
    addTearDown(bloc.close);

    bloc.add(SignatureSubmitted(participantId: 7, signature: Uint8List.fromList(<int>[1]), comment: ''));
    await _settle();

    expect(marks, <ContractChange>[ContractChange.updated]);
  });

  // Shartnoma matniga rozilik yuz so'rovi bilan birga ketadi
  // (`accepted_oferta: true`), shuning uchun o'qish aynan shu qadamni to'sadi.
  // Imzolash uchun matnni qayta o'qish talab qilinmaydi.
  group('shartnoma matnini o‘qish sharti', () {
    test('o‘qilmaguncha yuzni tasdiqlab bo‘lmaydi', () {
      final ContractSigningState state = ContractSigningState.initial(_signing());

      expect(state.canConfirmFace(_client), isFalse);
      expect(state.copyWith(isRead: true).canConfirmFace(_client), isTrue);
    });

    test('imzolash matn o‘qilishiga bog‘liq emas', () {
      final ContractSigningState state = ContractSigningState.initial(
        _signing(participants: <SigningParticipant>[_client.copyWith(isFaceChecked: true)]),
      );

      expect(state.isRead, isFalse);
      expect(state.canSign(state.signing.participants.first), isTrue);
    });

    test('yuzi tasdiqlangan ishtirokchiga yuz qadami qayta ochilmaydi', () {
      final ContractSigningState state = ContractSigningState.initial(_signing()).copyWith(isRead: true);

      expect(state.canConfirmFace(_guarantor), isFalse);
    });
  });
}