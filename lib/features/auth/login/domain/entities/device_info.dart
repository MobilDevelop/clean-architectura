class DeviceInfoModel {
  const DeviceInfoModel({
    required this.uniqueId,
    required this.name,
    required this.brand,
    required this.osVersion,
  });

  final String uniqueId;
  final String name;
  final String brand;
  final String osVersion;

  factory DeviceInfoModel.fromMap(Map<dynamic, dynamic> map) => DeviceInfoModel(
    uniqueId: map['uniqueId'] as String? ?? '',
    name: map['name'] as String? ?? '',
    brand: map['brand'] as String? ?? '',
    osVersion: map['osVersion'] as String? ?? '',
  );
}
