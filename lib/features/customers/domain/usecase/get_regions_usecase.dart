import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';

final class GetRegionsUsecase implements UseCase<List<Region>, int> {
  const GetRegionsUsecase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<List<Region>>> call(int params) => _repository.getRegions(params);
}
