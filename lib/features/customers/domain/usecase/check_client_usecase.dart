import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';

final class CheckClientUsecase implements UseCase<CustomerInfo,FaceCheckParams> {

  const CheckClientUsecase(this._repository);

  final CustomerRepository _repository;
  
  
  @override
  Future<Result<CustomerInfo>> call(FaceCheckParams params) => _repository.checkClient(params);

}