import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/core/usecase/usecase.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_search_params.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/workplace_repository.dart';

final class SearchWorkplacesUsecase implements UseCase<List<WorkplaceInfo>, WorkplaceSearchParams> {
  const SearchWorkplacesUsecase(this._repository);

  final WorkplaceRepository _repository;

  @override
  Future<Result<List<WorkplaceInfo>>> call(WorkplaceSearchParams params) => _repository.search(params);
}
