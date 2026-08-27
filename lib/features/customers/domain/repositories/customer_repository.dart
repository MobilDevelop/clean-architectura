import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';

abstract interface class CustomerRepository {

  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams search);
}