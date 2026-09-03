import 'dart:convert';

import 'package:colloborator_v3/core/services/local_cache.dart';
import 'package:colloborator_v3/features/customers/data/models/address_item_dto.dart';

/// Ma'lumotnomalarni diskda saqlaydi. Viloyat va tuman ro'yxati kamdan-kam
/// o'zgaradi, har ekran ochilishida so'rov yuborish esa qimmat.
final class AddressLocalDatasource {
  const AddressLocalDatasource({required this._cache});

  final LocalCache _cache;

  static const Duration _maxAge = Duration(hours: 24);

  /// Kalit versiyasi: saqlangan shakl o'zgarganda eski yozuvlar o'z-o'zidan
  /// e'tibordan qoladi.
  static const String _version = 'v2';

  static const String _provincesKey = 'provinces.$_version';

  String _regionsKey(int provinceId) => 'regions_$provinceId.$_version';

  String _villagesKey(int regionId) => 'villages_$regionId.$_version';

  Future<List<AddressItemDto>?> getProvinces() => _read(_provincesKey);

  Future<List<AddressItemDto>?> getRegions(int provinceId) => _read(_regionsKey(provinceId));

  Future<List<AddressItemDto>?> getVillages(int regionId) => _read(_villagesKey(regionId));

  Future<void> saveProvinces(List<AddressItemDto> items) => _write(_provincesKey, items);

  Future<void> saveRegions(int provinceId, List<AddressItemDto> items) => _write(_regionsKey(provinceId), items);

  Future<void> saveVillages(int regionId, List<AddressItemDto> items) => _write(_villagesKey(regionId), items);

  /// Buzuq yozuv xato emas — "keshda yo'q" deb hisoblanadi va serverga
  /// boriladi. Aks holda bir marta buzilgan kesh ekranni butunlay yopib
  /// qo'yardi.
  Future<List<AddressItemDto>?> _read(String key) async {
    final String? raw = await _cache.read(key: key, maxAge: _maxAge);
    if (raw == null) return null;

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      return decoded.whereType<Map<String, dynamic>>().map(AddressItemDto.fromJson).toList();
    } catch (_) {
      await _cache.remove(key);
      return null;
    }
  }

  Future<void> _write(String key, List<AddressItemDto> items) =>
      _cache.write(key: key, value: jsonEncode(items.map((AddressItemDto item) => item.toJson()).toList()));
}
