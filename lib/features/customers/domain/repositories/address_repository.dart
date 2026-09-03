import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';

/// Manzil ma'lumotnomasi: viloyat → tuman → mahalla.
abstract interface class AddressRepository {
  Future<Result<List<Province>>> getProvinces();

  Future<Result<List<Region>>> getRegions(int provinceId);

  Future<Result<List<Village>>> getVillages(int regionId);
}
