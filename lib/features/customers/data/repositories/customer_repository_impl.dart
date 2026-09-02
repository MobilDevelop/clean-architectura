import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/data/datasources/customer_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_search_param.dart';
import 'package:colloborator_v3/features/customers/domain/entities/face_check_params.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/customer_repository.dart';
import 'package:dio/dio.dart';

final class CustomerRepositoryImpl implements CustomerRepository{
  const CustomerRepositoryImpl({required this._remote});

  final CustomerRemoteDatasource _remote;

  @override
  Future<Result<List<CustomerInfo>>> getCustomers(CustomerSearchParams param)async{
    try {
      final dto = await _remote.getCustomers(param);
     return Ok(dto.map((customer) => customer.toEntity()).toList());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }

  @override
  Future<Result<CustomerInfo>> checkClient(FaceCheckParams params)async{
    try {
      final dto = await _remote.checkClient(params);

      if (dto == null) return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
      return Ok(dto.toEntity());

    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}