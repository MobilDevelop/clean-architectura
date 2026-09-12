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

  /// Xom satr qaytariladi: uni o'qish va buzuqligini hal qilish
  /// repositoryning ishi (4.7.4). Datasource xato ushlamaydi (4.3) — ilgari
  /// `jsonDecode` shu yerda `try/catch` bilan o'ralgan edi.
  Future<String?> readProvinces() => _cache.read(key: _provincesKey, maxAge: _maxAge);

  Future<String?> readRegions(int provinceId) => _cache.read(key: _regionsKey(provinceId), maxAge: _maxAge);

  Future<String?> readVillages(int regionId) => _cache.read(key: _villagesKey(regionId), maxAge: _maxAge);

  /// Buzuq yozuvni tashlab yuborish — repository shuni chaqiradi.
  Future<void> dropProvinces() => _cache.remove(_provincesKey);

  Future<void> dropRegions(int provinceId) => _cache.remove(_regionsKey(provinceId));

  Future<void> dropVillages(int regionId) => _cache.remove(_villagesKey(regionId));

  Future<void> saveProvinces(List<AddressItemDto> items) => _write(_provincesKey, items);

  Future<void> saveRegions(int provinceId, List<AddressItemDto> items) => _write(_regionsKey(provinceId), items);

  Future<void> saveVillages(int regionId, List<AddressItemDto> items) => _write(_villagesKey(regionId), items);

  Future<void> _write(String key, List<AddressItemDto> items) =>
      _cache.write(key: key, value: jsonEncode(items.map((AddressItemDto item) => item.toJson()).toList()));
}
