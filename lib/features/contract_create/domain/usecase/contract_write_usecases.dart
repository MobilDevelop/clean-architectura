import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_write_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/contract_create_repository.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/delete_product_params.dart';
import 'package:colloborator_v3/features/contract_create/domain/repositories/special_tariff_repository.dart';

final class UpdateProductUsecase implements UseCase<void, UpdateProductParams> {
  const UpdateProductUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<void>> call(UpdateProductParams params) => _repository.updateProduct(params);
}

/// Tovarni o'chiradi va biriktirilgan tarifni bekor qiladi — sabab
/// [AddProductUsecase] dagi bilan bir xil.
final class DeleteProductUsecase implements UseCase<void, DeleteProductParams> {
  const DeleteProductUsecase(this._repository, this._tariffs);

  final ContractCreateRepository _repository;
  final SpecialTariffRepository _tariffs;

  @override
  Future<Result<void>> call(DeleteProductParams params) async {
    final Result<void> removed = await _repository.deleteProduct(params.productId);

    if (removed is Err<void>) return removed;

    await _tariffs.remove(params.contractId);

    return removed;
  }
}

final class GetPaymentDaysUsecase implements UseCase<List<int>, int> {
  const GetPaymentDaysUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<List<int>>> call(int params) => _repository.getPaymentDays(params);
}

/// Shartnomani skoringga yuboradi.
final class SubmitContractUsecase implements UseCase<void, SubmitContractParams> {
  const SubmitContractUsecase(this._repository);

  final ContractCreateRepository _repository;

  @override
  Future<Result<void>> call(SubmitContractParams params) => _repository.submit(params);
}
