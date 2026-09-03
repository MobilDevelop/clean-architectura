import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';

abstract interface class CustomerRepository {

  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams search);
  Future<Result<CustomerInfo>> checkClient(FaceCheckParams params);
  Future<Result<void>> updateCustomer(CustomerUpdateParams params);
  Future<Result<ScoringInfo>> getScoring(int customerId);
}