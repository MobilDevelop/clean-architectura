import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/contract_authority.dart';
import 'package:colloborator_v3/features/contracts/domain/repositories/contracts_repository.dart';

final class GetAuthorityUsecase implements UseCase<ContractAuthority, int> {
  const GetAuthorityUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<ContractAuthority>> call(int params) => _repository.getAuthority(params);
}

/// O'ziga eskalatsiya qilingan shartnomaga ruxsat berish.
final class ConfirmAuthorityUsecase implements UseCase<void, int> {
  const ConfirmAuthorityUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<void>> call(int params) => _repository.confirmAuthority(params);
}

/// Shartnomani matritsa ko'rsatgan darajaga yo'naltirish.
final class EscalateAuthorityUsecase implements UseCase<void, int> {
  const EscalateAuthorityUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<void>> call(int params) => _repository.escalateAuthority(params);
}

/// Eski dvijokda ruxsat berish va yuqoriga yuborish bitta so'rov.
final class AllowConfirmationUsecase implements UseCase<void, int> {
  const AllowConfirmationUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<void>> call(int params) => _repository.allowConfirmation(params);
}

final class CancelContractUsecase implements UseCase<void, int> {
  const CancelContractUsecase(this._repository);

  final ContractRepository _repository;

  @override
  Future<Result<void>> call(int params) => _repository.cancelContract(params);
}
