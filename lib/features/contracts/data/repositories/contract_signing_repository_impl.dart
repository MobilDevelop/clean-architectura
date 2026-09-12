import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/contracts/data/datasources/contract_signing_remote_datasource.dart';
import 'package:colloborator_v3/features/contracts/data/models/signature_result_dto.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_signing.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contract_signing_repository.dart';

final class ContractSigningRepositoryImpl implements ContractSigningRepository {
  const ContractSigningRepositoryImpl({required this._remote});

  final ContractSigningRemoteDatasource _remote;

  @override
  Future<Result<String>> getContractFile(ContractFileParams params) => guard(() async {
    final String file = await _remote.getContractFile(params);

    // HTTP 200 bilan kelgan bo'sh hujjat ham xato: foydalanuvchi o'qimagan
    // shartnomaga rozilik bera olmaydi, bo'sh ekran esa buni yashirardi (5.8).
    if (file.trim().isEmpty) throw const FormatException('electronic_contract bo‘sh');

    return file;
  });

  @override
  Future<Result<void>> confirmFace(FaceConfirmParams params) => guard(() => _remote.confirmFace(params));

  @override
  Future<Result<SignatureResult>> sign(SignatureParams params) => guard(() async {
    final SignatureResultDto? dto = await _remote.sign(params);
    final SignatureResult? result = dto?.toEntity();

    // Havolasiz imzo — imzo emas: ekranda "imzolangan" deb ko'rinardi-yu,
    // ro'yxat yangilanganda holat qaytib kelardi.
    if (result == null || result.signUrl.isEmpty) {
      throw const FormatException('sign_contract imzo havolasini qaytarmadi');
    }

    return result;
  });
}
