import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';

abstract interface class ContractSigningRepository {
  /// Shartnoma matni — HTML. Flex shartnomasi boshqa endpointdan keladi.
  Future<Result<String>> getContractFile(ContractFileParams params);

  /// Ishtirokchining yuzini tasdiqlaydi.
  Future<Result<void>> confirmFace(FaceConfirmParams params);

  Future<Result<SignatureResult>> sign(SignatureParams params);
}
