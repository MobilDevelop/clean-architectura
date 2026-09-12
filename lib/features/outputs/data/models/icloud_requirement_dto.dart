import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/icloud_requirement.dart';

int _int(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

int? _nullableInt(Object? raw) => raw == null ? null : num.tryParse(raw.toString())?.toInt();

String _text(Object? raw) => raw?.toString() ?? '';

/// `GET icloud-contracts/requirements` javobi.
final class IcloudRequirementsDto {
  const IcloudRequirementsDto(this._json);

  factory IcloudRequirementsDto.fromJson(Map<String, dynamic> json) => IcloudRequirementsDto(json);

  final Map<String, dynamic> _json;

  /// `is_satisfied` kelmasa **talab bajarilmagan** deb qaraladi.
  ///
  /// Nega `false`: `true` zaxira qiymati kalit yo'qolganda chiqimni ochib
  /// yuborardi, ya'ni tekshiruvni jimgina o'chirib qo'yardi. Yo'nalishi
  /// noto'g'ri zaxira qiymat — buzilishni qonuniy holatga aylantiradi (4.6).
  IcloudRequirements toEntity() => IcloudRequirements(
    contractId: _int(_json['contract_id']),
    isSatisfied: _json['is_satisfied'] == true,
    devices: JsonParser.list(_json['items'], fromJson: IcloudDeviceDto.fromJson)
        .map((IcloudDeviceDto dto) => dto.toEntity())
        .toList(),
  );
}

/// Talab qo'yilgan qurilma.
final class IcloudDeviceDto {
  const IcloudDeviceDto(this._json);

  factory IcloudDeviceDto.fromJson(Map<String, dynamic> json) => IcloudDeviceDto(json);

  final Map<String, dynamic> _json;

  IcloudDevice toEntity() => IcloudDevice(
    contractProductId: _int(_json['contract_product_id']),
    productId: _int(_json['product_variant_id']),
    name: _text(_json['name']),
    fullName: _text(_json['full_name']),
    imei: _text(_json['imei']),
    imei2: _text(_json['imei2']),
    missing: _nullableInt(_json['missing']),
  );
}

/// `POST icloud-contracts` tanasi.
///
/// Nega DTO'da: `IcloudCredential` — domain obyekti va unda `toJson()`
/// bo'lmaydi (12-bo'lim). Backend kalitlari faqat shu yerda turadi.
abstract final class IcloudCredentialBody {
  /// Apple ID egasining serverdagi yozuvi.
  ///
  /// Ikkalasi ham «o'ziniki» degan ma'noni beradi, faqat ikki xil tilda —
  /// flex shu ikki qatorni yuboradi va backend aynan shularni kutadi.
  /// Ma'nosi backenddan so'ralgan.
  static String owner(AppleIdOwner value) => switch (value) {
    AppleIdOwner.own => 'OZINIKI',
    AppleIdOwner.personal => 'Личный',
  };

  static Map<String, dynamic> of(IcloudCredential credential) => <String, dynamic>{
    'contract_id': credential.contractId,
    'contract_product_id': credential.contractProductId,
    'product_status': credential.condition.trim(),
    'has_box': credential.hasBox ?? false,
    'imei': credential.imei.trim(),
    'imei2': credential.imei2.trim(),
    'serial_number': credential.serialNumber.trim(),
    'icloud_login': credential.login.trim(),
    'icloud_password': credential.password,
    'apple_id_login': _owner(credential.appleLogin),
    'apple_id_password': _owner(credential.applePassword),
    'restriction_code': credential.restrictionCode.trim(),
    'icloud_phone': credential.phone,
  };

  /// Tanlanmagan qiymat bu yergacha yetib kelmaydi — usecase uni to'sadi.
  /// Tip esa `null` ni baribir talab qiladi.
  static String _owner(AppleIdOwner? value) => value == null ? '' : owner(value);
}
