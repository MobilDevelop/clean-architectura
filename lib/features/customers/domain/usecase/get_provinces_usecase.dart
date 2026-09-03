import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';

final class GetProvincesUsecase implements UseCase<List<Province>, NoParams> {
  const GetProvincesUsecase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<List<Province>>> call(NoParams params) => _repository.getProvinces();
}
