import 'package:flutter/services.dart';

/// Backend login so'rovida talab qiladigan qurilma ma'lumoti.
/// Maydon nomlari native tomondagi map kalitlariga aynan mos.
final class DeviceInfo {
  const DeviceInfo({
    required this.uniqueId,
    required this.name,
    required this.brand,
    required this.osVersion,
  });

  const DeviceInfo.empty()
      : uniqueId = '',
        name = '',
        brand = '',
        osVersion = '';

  factory DeviceInfo.fromMap(Map<Object?, Object?> map) => DeviceInfo(
        uniqueId: map['uniqueId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        brand: map['brand'] as String? ?? '',
        osVersion: map['osVersion'] as String? ?? '',
      );

  final String uniqueId;
  final String name;
  final String brand;
  final String osVersion;
}

/// Qurilma ma'lumotini native tomondan bir marta o'qib keshlaydi.
///
/// Nega platform channel: backend qurilmani `Settings.Secure.ANDROID_ID`
/// bo'yicha ro'yxatga oladi, uni esa hech bir Flutter paketi bermaydi
/// (`device_info_plus` dan 4.0 versiyasida olib tashlangan).
class DeviceInfoService {
  DeviceInfoService(this._channel);

  final MethodChannel _channel;

  DeviceInfo? _cached;

  Future<DeviceInfo> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final info = await _read();
    _cached = info;


    return info;
  }

  Future<DeviceInfo> _read() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>('getDeviceInfo');
      if (result == null) return const DeviceInfo.empty();

      return DeviceInfo.fromMap(result);
    } on PlatformException {
      return const DeviceInfo.empty();
    } on MissingPluginException {
      return const DeviceInfo.empty();
    }
  }
}
