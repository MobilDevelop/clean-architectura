import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_search_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';

abstract interface class WorkplaceRepository {
  Future<Result<List<WorkplaceInfo>>> search(WorkplaceSearchParams params);
}
