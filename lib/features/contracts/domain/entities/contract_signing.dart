import 'dart:io';
import 'dart:typed_data';

import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_info.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';
import 'package:equatable/equatable.dart';

/// Imzolash oynasidagi ishtirokchi: mijoz yoki kafil.
///
/// Ikkalasi bitta tipda: ekran ular bilan bir xil ishlaydi, farq faqat qaysi
/// endpointga borishida. Flex'da mijoz va kafil holati ikkita alohida joyda
/// saqlanardi (`isClientSigned` + `guarantors`) va har bir tekshiruv ikki
/// tarmoqqa bo'linardi.
final class SigningParticipant extends Equatable {
  const SigningParticipant({
    required this.id,
    required this.isClient,
    required this.name,
    required this.passport,
    required this.birthday,
    required this.phone,
    required this.isFaceChecked,
    required this.signUrl,
  });

  /// Mijoz id si yoki kafil id si. Ular to'qnashmaydi: mijozning o'zini kafil
  /// qilib bo'lmaydi.
  final int id;

  final bool isClient;
  final String name;
  final String passport;

  /// `dd.MM.yyyy` — yuz tekshiruvi so'rovi aynan shu shaklni kutadi.
  final String birthday;
  final String phone;

  final bool isFaceChecked;

  /// Imzo rasmiga havola. Bo'sh — hali imzolanmagan.
  final String signUrl;

  bool get isSigned => signUrl.isNotEmpty;

  /// Imzolash uchun yagona shart — o'z yuzini tasdiqlagan bo'lishi. Navbat
  /// yo'q: har bir ishtirokchi mustaqil imzolaydi.
  bool get canSign => isFaceChecked && !isSigned;

  SigningParticipant copyWith({bool? isFaceChecked, String? signUrl}) => SigningParticipant(
    id: id,
    isClient: isClient,
    name: name,
    passport: passport,
    birthday: birthday,
    phone: phone,
    isFaceChecked: isFaceChecked ?? this.isFaceChecked,
    signUrl: signUrl ?? this.signUrl,
  );

  @override
  List<Object?> get props => <Object?>[id, isClient, name, passport, birthday, phone, isFaceChecked, signUrl];
}

/// Imzolanayotgan shartnoma.
final class ContractSigning extends Equatable {
  const ContractSigning({required this.contractId, required this.isFlex, required this.participants});

  /// Ro'yxatdagi shartnomadan imzolash holatini yig'adi.
  ///
  /// Mijoz birinchi, keyin kafillar — akkordeon tartibi shu.
  factory ContractSigning.of(ContractInfo contract) => ContractSigning(
    contractId: contract.id,
    isFlex: contract.flex,
    participants: <SigningParticipant>[
      SigningParticipant(
        id: contract.clientId,
        isClient: true,
        name: contract.clientFio,
        passport: contract.passport,
        birthday: contract.birthDay,
        phone: '',
        // Status `faceVerified` (9) — mijozning yuzi allaqachon tekshirilgan,
        // bayroq esa eski javoblarda kelmasligi mumkin (flex ham ikkalasiga
        // qaraydi).
        isFaceChecked: contract.isClientFace || contract.status == ContractStatus.faceVerified,
        signUrl: contract.clientSignUrl,
      ),
      for (final GuarantorInfo guarantor in contract.guarantors)
        SigningParticipant(
          id: guarantor.id,
          isClient: false,
          name: guarantor.name,
          passport: guarantor.passport,
          birthday: guarantor.birthday,
          phone: guarantor.phone,
          isFaceChecked: guarantor.isFaceCheck,
          signUrl: guarantor.signUrl,
        ),
    ],
  );

  final int contractId;

  /// Flex shartnomasining matni boshqa endpointdan keladi.
  final bool isFlex;

  /// Mijoz birinchi, keyin kafillar.
  final List<SigningParticipant> participants;

  int get signedCount => participants.where((SigningParticipant p) => p.isSigned).length;

  /// Shartnoma faqat mijoz va **barcha** kafillar imzolagandan keyin rasmiylashadi.
  ///
  /// Bo'sh ro'yxat "hammasi imzolangan" degani emas: ishtirokchisiz shartnoma
  /// bo'lmaydi, bo'sh ro'yxat esa o'qishdagi nosozlik belgisi.
  bool get isAllSigned => participants.isNotEmpty && participants.every((SigningParticipant p) => p.isSigned);

  SigningParticipant? participantOf(int id) {
    for (final SigningParticipant participant in participants) {
      if (participant.id == id) return participant;
    }

    return null;
  }

  /// Bitta ishtirokchini almashtiradi. Natija yangi obyekt — holat o'zgarmas.
  ContractSigning withParticipant(SigningParticipant updated) => ContractSigning(
    contractId: contractId,
    isFlex: isFlex,
    participants: participants
        .map((SigningParticipant p) => p.id == updated.id ? updated : p)
        .toList(),
  );

  @override
  List<Object?> get props => <Object?>[contractId, isFlex, participants];
}

/// `confirm_client_face` / `confirm_guarantor_face` so'rovi.
final class FaceConfirmParams extends Equatable {
  const FaceConfirmParams({required this.contractId, required this.participant, required this.photo});

  final int contractId;
  final SigningParticipant participant;

  /// Kamera sahifasi 720px ga siqib bergan surat.
  final File photo;

  @override
  List<Object?> get props => <Object?>[contractId, participant, photo.path];
}

/// `sign_client_contract` / `sign_guarantor_contract` so'rovi.
final class SignatureParams extends Equatable {
  const SignatureParams({
    required this.contractId,
    required this.participant,
    required this.signature,
    required this.comment,
  });

  final int contractId;
  final SigningParticipant participant;

  /// Imzoning PNG baytlari.
  final Uint8List signature;

  /// Ixtiyoriy izoh. Bo'sh satr — izoh yo'q.
  final String comment;

  @override
  List<Object?> get props => <Object?>[contractId, participant, signature.length, comment];
}

/// Imzo yuborilgandan keyingi natija.
final class SignatureResult extends Equatable {
  const SignatureResult({required this.signUrl, required this.isContractSigned});

  /// Serverdagi imzo rasmi. Bo'sh bo'lsa — javob kutilgan shaklda emas.
  final String signUrl;

  /// Server HTTP 201 bilan "shartnoma to'liq imzolandi" dedi.
  ///
  /// Bu yagona manba emas: ekran o'zi ham hisoblaydi (`isAllSigned`). Server
  /// 201 ni har doim qaytarishi tasdiqlanmagan (backendga savol), shuning
  /// uchun ikkala yo'l ham qoldirilgan.
  final bool isContractSigned;

  @override
  List<Object?> get props => <Object?>[signUrl, isContractSigned];
}

/// Shartnoma matnini so'rash.
final class ContractFileParams extends Equatable {
  const ContractFileParams({required this.contractId, required this.isFlex});

  final int contractId;
  final bool isFlex;

  @override
  List<Object?> get props => <Object?>[contractId, isFlex];
}
