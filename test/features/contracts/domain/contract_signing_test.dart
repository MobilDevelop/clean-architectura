import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Imzolash qoidalari — sof Dart, kamerasiz va tarmoqsiz sinaladi (9.1).
///
/// Flex'da mijoz va kafil holati ikkita alohida joyda turardi
/// (`isClientSigned` + `guarantors`), va har bir tekshiruv ikki tarmoqqa
/// bo'linardi. Bu yerda ikkalasi bitta ro'yxat.
ContractInfo _contract({
  int statusCode = 8,
  bool isClientFace = false,
  String clientSignUrl = '',
  List<GuarantorInfo> guarantors = const <GuarantorInfo>[],
}) => ContractInfo(
  id: 55,
  clientId: 7,
  clientFio: 'Aliyev Vali',
  status: ContractStatus.fromCode(statusCode),
  birthDay: '12.03.1990',
  passport: 'AB1234567',
  isFormal: true,
  isReturned: false,
  isCard: false,
  flex: false,
  createdAt: '',
  guarantors: guarantors,
  clientSignUrl: clientSignUrl,
  isClientFace: isClientFace,
  higherPositionConfirmationRequired: false,
  isSentForApproval: false,
  canUserAllowConfirmation: false,
  sentUserFullname: '',
  sentPartnerFullname: '',
  showButtonKATM: false,
  hasBenefit: false,
  engine: AuthorityEngine.legacy,
  statusCode: statusCode,
);

GuarantorInfo _guarantor({required int id, bool isFaceCheck = false, String signUrl = ''}) => GuarantorInfo(
  id: id,
  name: 'Kafil $id',
  inps: '',
  passport: 'CD765432$id',
  birthday: '01.01.1985',
  phone: '998901234567',
  isFaceCheck: isFaceCheck,
  signUrl: signUrl,
);

void main() {
  test('mijoz birinchi, keyin kafillar', () {
    final ContractSigning signing = ContractSigning.of(
      _contract(guarantors: <GuarantorInfo>[_guarantor(id: 21), _guarantor(id: 22)]),
    );

    expect(signing.participants.length, 3);
    expect(signing.participants.first.isClient, isTrue);
    expect(signing.participants.map((SigningParticipant p) => p.id), <int>[7, 21, 22]);
  });

  // Bayroq eski javoblarda kelmasligi mumkin, status esa aniq aytadi.
  test('status `faceVerified` (9) mijoz yuzi tasdiqlangani bilan bir xil', () {
    expect(ContractSigning.of(_contract(statusCode: 9)).participants.first.isFaceChecked, isTrue);
    expect(ContractSigning.of(_contract(isClientFace: true)).participants.first.isFaceChecked, isTrue);
    expect(ContractSigning.of(_contract()).participants.first.isFaceChecked, isFalse);
  });

  test('imzolash uchun yagona shart — yuz tasdig‘i, navbat yo‘q', () {
    final ContractSigning signing = ContractSigning.of(
      _contract(guarantors: <GuarantorInfo>[_guarantor(id: 21, isFaceCheck: true)]),
    );

    // Mijoz hali yuzini tasdiqlamagan, kafil esa tasdiqlagan — kafil
    // mijozdan oldin imzolay oladi.
    expect(signing.participants.first.canSign, isFalse);
    expect(signing.participantOf(21)?.canSign, isTrue);
  });

  test('imzolagan ishtirokchi ikkinchi marta imzolamaydi', () {
    final SigningParticipant signed = ContractSigning.of(
      _contract(isClientFace: true, clientSignUrl: 'https://s3/sign.png'),
    ).participants.first;

    expect(signed.isSigned, isTrue);
    expect(signed.canSign, isFalse);
  });

  test('shartnoma hamma imzolagandan keyin yakunlanadi', () {
    ContractSigning signing = ContractSigning.of(
      _contract(
        isClientFace: true,
        guarantors: <GuarantorInfo>[_guarantor(id: 21, isFaceCheck: true)],
      ),
    );

    expect(signing.isAllSigned, isFalse);
    expect(signing.signedCount, 0);

    signing = signing.withParticipant(signing.participants.first.copyWith(signUrl: 'https://s3/a.png'));
    expect(signing.isAllSigned, isFalse);
    expect(signing.signedCount, 1);

    final SigningParticipant guarantor = signing.participants.last;
    signing = signing.withParticipant(guarantor.copyWith(signUrl: 'https://s3/b.png'));

    expect(signing.isAllSigned, isTrue);
    expect(signing.signedCount, 2);
  });

  // Ishtirokchisiz shartnoma bo'lmaydi: bo'sh ro'yxat o'qishdagi nosozlik
  // belgisi, "hammasi imzolangan" degani emas.
  test('bo‘sh ro‘yxat yakunlangan deb hisoblanmaydi', () {
    const ContractSigning empty = ContractSigning(
      contractId: 1,
      isFlex: false,
      participants: <SigningParticipant>[],
    );

    expect(empty.isAllSigned, isFalse);
  });
}
