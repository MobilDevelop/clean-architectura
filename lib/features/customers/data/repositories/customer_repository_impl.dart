import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/models/customer_info_dto.dart';
import 'package:colloborator_v3/features/customers/data/models/scoring_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/scoring_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';

final class CustomerRepositoryImpl implements CustomerRepository {
  const CustomerRepositoryImpl({required this._remote});

  final CustomerRemoteDatasource _remote;

  @override
  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams param) => guard(() async {
    final List<CustomerInfoDto> dto = await _remote.getCustomers(param);

    return dto.map((CustomerInfoDto customer) => customer.toEntity()).toList();
  });

  /// Javob o'qilmasa istisno otiladi — `guard` uni `ParseFailure` ga o'giradi
  /// va nosozlik botga yetadi (5.7). Qo'lda `Err` qaytarilsa xabar berilmay
  /// qolardi.
  @override
  Future<Result<CustomerInfo>> checkClient(FaceCheckParams params) => guard(() async {
    final CustomerInfoDto? dto = await _remote.checkClient(params);

    if (dto == null) throw const FormatException('checkClient javobi obyekt emas');

    return dto.toEntity();
  });

  @override
  Future<Result<ScoringInfo>> getScoring(int customerId) => guard(() async {
    final ScoringInfoDto? dto = await _remote.getScoring(customerId);

    if (dto == null) throw const FormatException('getScoring javobi obyekt emas');

    return dto.toEntity();
  });

  @override
  Future<Result<void>> updateCustomer(CustomerUpdateParams params) =>
      guard(() => _remote.updateCustomer(params));
}
