import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';

/// Uchala ma'lumotnoma ham bir xil shaklda keladi: `{id, name}`.
///
/// Kalit aynan `name` — mijoz obyekti ichidagi viloyat ham shu kalit bilan
/// o'qiladi (`ProvinceDto`).
final class AddressItemDto {
  const AddressItemDto({required this.id, required this.title});

  factory AddressItemDto.fromJson(Map<String, dynamic> json) =>
      AddressItemDto(id: json['id'] as int, title: json['name'] as String);

  final int id;
  final String title;

  /// Kesh `fromJson` bilan qayta o'qiladi, shuning uchun kalit bir xil bo'ladi.
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': title};

  Province toProvince() => Province(id: id, title: title);

  Region toRegion() => Region(id: id, title: title);

  Village toVillage() => Village(id: id, title: title);
}
