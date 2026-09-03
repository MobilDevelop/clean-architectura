import 'package:colloborator_v3/core/error/error_mapper.dart';
import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_local_datasource.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/models/address_item_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';
import 'package:dio/dio.dart';

final class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl({required this._remote, required this._local});

  final AddressRemoteDatasource _remote;
  final AddressLocalDatasource _local;

  @override
  Future<Result<List<Province>>> getProvinces() => _load(
    cached: _local.getProvinces,
    fetch: _remote.getProvinces,
    save: _local.saveProvinces,
    toEntity: (AddressItemDto dto) => dto.toProvince(),
  );

  @override
  Future<Result<List<Region>>> getRegions(int provinceId) => _load(
    cached: () => _local.getRegions(provinceId),
    fetch: () => _remote.getRegions(provinceId),
    save: (List<AddressItemDto> items) => _local.saveRegions(provinceId, items),
    toEntity: (AddressItemDto dto) => dto.toRegion(),
  );

  @override
  Future<Result<List<Village>>> getVillages(int regionId) => _load(
    cached: () => _local.getVillages(regionId),
    fetch: () => _remote.getVillages(regionId),
    save: (List<AddressItemDto> items) => _local.saveVillages(regionId, items),
    toEntity: (AddressItemDto dto) => dto.toVillage(),
  );

  /// Uchala ro'yxat bir xil yo'ldan o'tadi: avval kesh, bo'lmasa server.
  Future<Result<List<T>>> _load<T>({
    required Future<List<AddressItemDto>?> Function() cached,
    required Future<List<AddressItemDto>> Function() fetch,
    required Future<void> Function(List<AddressItemDto>) save,
    required T Function(AddressItemDto) toEntity,
  }) async {
    try {
      final List<AddressItemDto>? saved = await cached();
      if (saved != null && saved.isNotEmpty) return Ok(saved.map(toEntity).toList());

      final List<AddressItemDto> fresh = await fetch();

      // Keshga yozib bo'lmasa ham ma'lumot qo'lda: diskdagi nosozlik tayyor
      // javobni xatoga aylantirmasligi kerak.
      try {
        await save(fresh);
      } catch (_) {}

      return Ok(fresh.map(toEntity).toList());
    } on DioException catch (e) {
      return Err(ErrorMapper.fromDio(e));
    } on TypeError catch (_) {
      return const Err(ParseFailure('Server javobi kutilgan shaklda emas'));
    } catch (_) {
      return const Err(UnknownFailure('Kutilmagan xatolik yuz berdi'));
    }
  }
}
