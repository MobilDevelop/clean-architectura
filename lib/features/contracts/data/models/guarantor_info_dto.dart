import 'package:colloborator_v3/core/utils/json_value.dart';
import 'package:colloborator_v3/features/contracts/domain/entities/guarantor_info.dart';

final class GuarantorInfoDto {

 const  GuarantorInfoDto({required this.id,required this.name,required this.inps,required this.passport,required this.birthday,required this.phone,required this.isFaceCheck,required this.signUrl});

  final int id;
  final String name;
  final String inps;
  final String passport;
  final String birthday;
  final String phone;
  final String signUrl;
  final bool isFaceCheck;

  GuarantorInfo toEntity()=>GuarantorInfo(
    id: id, 
    name: name, 
    inps: inps, 
    passport: passport, 
    birthday: birthday, 
    phone: phone, 
    isFaceCheck: isFaceCheck, 
    signUrl: signUrl
  );

  /// Imzolash shu id bilan ishlaydi — yo'qolsa jimgina `0`ga aylantirib
  /// bo'lmaydi (4.6).
  factory GuarantorInfoDto.fromJson(Map<String,dynamic> json)=>GuarantorInfoDto(
    id: JsonValue.requireInt(json['id'], field: 'guarantor.id'),
    name: json['client_fio'] as String? ?? "",
    inps: json['client_inps'] as String? ?? "",
    passport: json['passport_series_number'] as String? ?? "",
    birthday: json['birth_date'] as String? ?? "",
    phone: json['phone_number'] as String? ?? "",
    signUrl: json['guarantor_sign_url'] as String? ?? "",
    isFaceCheck: json['is_guarantor_face_id_verified'] as bool? ?? false,
  );
}