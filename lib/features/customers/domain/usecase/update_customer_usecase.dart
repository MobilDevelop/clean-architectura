import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';

final class UpdateCustomerUsecase implements UseCase<void, CustomerUpdateParams> {
  const UpdateCustomerUsecase(this._repository);

  final CustomerRepository _repository;

  @override
  Future<Result<void>> call(CustomerUpdateParams params) => _repository.updateCustomer(params);
}
