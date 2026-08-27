import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';

final class CustomerUsecase implements UseCase<List<CustomerInfo>,CustomerSearchParams> {

  const CustomerUsecase(this._repository);

  final CustomerRepository _repository;

  @override
  Future<Result<List<CustomerInfo>>> call(CustomerSearchParams params) => _repository.getCustomers(params);
}