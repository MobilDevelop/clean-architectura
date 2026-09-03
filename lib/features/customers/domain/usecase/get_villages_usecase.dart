import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';

final class GetVillagesUsecase implements UseCase<List<Village>, int> {
  const GetVillagesUsecase(this._repository);

  final AddressRepository _repository;

  @override
  Future<Result<List<Village>>> call(int params) => _repository.getVillages(params);
}
