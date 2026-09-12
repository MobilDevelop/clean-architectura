import 'dart:convert';

import 'package:colloborator_v3/core/error/failure.dart';
import 'package:colloborator_v3/core/error/result_guard.dart';
import 'package:colloborator_v3/core/result/result.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_local_datasource.dart';
import 'package:colloborator_v3/features/customers/data/datasources/address_remote_datasource.dart';
import 'package:colloborator_v3/features/customers/data/models/address_item_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/repositories/address_repository.dart';

final class AddressRepositoryImpl implements AddressRepository {
  const AddressRepositoryImpl({required this._remote, required this._local});

  final AddressRemoteDatasource _remote;
  final AddressLocalDatasource _local;

  @override
  Future<Result<List<Province>>> getProvinces() => _load(
    read: _local.readProvinces,
    drop: _local.dropProvinces,
    fetch: _remote.getProvinces,
    save: _local.saveProvinces,
    toEntity: (AddressItemDto dto) => dto.toProvince(),
  );

  @override
  Future<Result<List<Region>>> getRegions(int provinceId) => _load(
    read: () => _local.readRegions(provinceId),
    drop: () => _local.dropRegions(provinceId),
    fetch: () => _remote.getRegions(provinceId),
    save: (List<AddressItemDto> items) => _local.saveRegions(provinceId, items),
    toEntity: (AddressItemDto dto) => dto.toRegion(),
  );

  @override
  Future<Result<List<Village>>> getVillages(int regionId) => _load(
    read: () => _local.readVillages(regionId),
    drop: () => _local.dropVillages(regionId),
    fetch: () => _remote.getVillages(regionId),
    save: (List<AddressItemDto> items) => _local.saveVillages(regionId, items),
    toEntity: (AddressItemDto dto) => dto.toVillage(),
  );

  /// Uchala ro'yxat bir xil yo'ldan o'tadi: avval kesh, bo'lmasa server.
  Future<Result<List<T>>> _load<T>({
    required Future<String?> Function() read,
    required Future<void> Function() drop,
    required Future<List<AddressItemDto>> Function() fetch,
    required Future<void> Function(List<AddressItemDto>) save,
    required T Function(AddressItemDto) toEntity,
  }) => guard(() async {
    final List<AddressItemDto>? cached = await _decode(read, drop);
    if (cached != null && cached.isNotEmpty) return cached.map(toEntity).toList();

    final List<AddressItemDto> fresh = await fetch();

    // Keshga yozib bo'lmasa ham ma'lumot qo'lda: diskdagi nosozlik tayyor
    // javobni xatoga aylantirmasligi kerak. Sabab yo'qolmasin deb botga
    // xabar beriladi (5.8: yashiriladigan narsa — sabab emas, hodisaning
    // foydalanuvchiga ta'siri).
    try {
      await save(fresh);
    } catch (error, trace) {
      GuardReport.reporter?.call(const UnknownFailure('Manzil keshiga yozib bo\'lmadi'), error, trace);
    }

    return fresh.map(toEntity).toList();
  });

  /// Keshdagi yozuvni o'qiydi va u kutilgan shaklda ekanini tekshiradi (4.7.4).
  ///
  /// Buzuq yozuv xato emas — "keshda yo'q" deb hisoblanadi va serverga
  /// boriladi. Aks holda bir marta buzilgan kesh ekranni butunlay yopib
  /// qo'yardi. Yozuv o'sha zahoti o'chiriladi, aks holda u har ochilishda
  /// qayta o'qilib, har safar bekorga ishlatilardi.
  ///
  /// Nega bu yerda, datasource'da emas: datasource xato ushlamaydi (4.3).
  Future<List<AddressItemDto>?> _decode(
    Future<String?> Function() read,
    Future<void> Function() drop,
  ) async {
    final String? raw = await read();
    if (raw == null) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) {
        await drop();
        return null;
      }

      return decoded.whereType<Map<String, dynamic>>().map(AddressItemDto.fromJson).toList();
    } catch (_) {
      await drop();
      return null;
    }
  }
}
