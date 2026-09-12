import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contract_signing_repository.dart';

final class GetContractFileUsecase implements UseCase<String, ContractFileParams> {
  const GetContractFileUsecase(this._repository);

  final ContractSigningRepository _repository;

  @override
  Future<Result<String>> call(ContractFileParams params) => _repository.getContractFile(params);
}

final class ConfirmParticipantFaceUsecase implements UseCase<void, FaceConfirmParams> {
  const ConfirmParticipantFaceUsecase(this._repository);

  final ContractSigningRepository _repository;

  @override
  Future<Result<void>> call(FaceConfirmParams params) => _repository.confirmFace(params);
}

/// Imzoni yuboradi.
///
/// Imzolash shartini shu yerda tekshiradi (3.8): yuzi tasdiqlanmagan yoki
/// allaqachon imzolagan ishtirokchi uchun so'rov umuman ketmaydi. Ekran
/// tugmani o'chirib qo'yadi, lekin qoida ekranda emas, shu yerda turadi —
/// ikkinchi kirish yo'li paydo bo'lsa u ham shu tekshiruvdan o'tadi.
final class SignContractUsecase implements UseCase<SignatureResult, SignatureParams> {
  const SignContractUsecase(this._repository);

  final ContractSigningRepository _repository;

  @override
  Future<Result<SignatureResult>> call(SignatureParams params) async {
    if (params.participant.isSigned) {
      return const Err<SignatureResult>(ClientFailure('Bu ishtirokchi allaqachon imzolagan'));
    }

    if (!params.participant.isFaceChecked) {
      return const Err<SignatureResult>(ClientFailure('Avval yuzni tasdiqlash kerak'));
    }

    if (params.signature.isEmpty) {
      return const Err<SignatureResult>(ClientFailure('Imzo chizilmagan'));
    }

    return _repository.sign(params);
  }
}
