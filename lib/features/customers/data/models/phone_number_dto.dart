
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';

final class PhoneNumberDto{

  const PhoneNumberDto({required this.id,required this.phone,required this.isMain, required this.comment});

  /// Faqat raqamning o'zi majburiy — qolgani kelmasligi mumkin.
  factory PhoneNumberDto.fromJson(Map<String,dynamic> json)=>PhoneNumberDto(
    id: json['id'] as int? ?? 0,
    phone: json['phone_number'] as String,
    isMain: json['is_main'] as bool? ?? false,
    comment: json['comment'] as String? ?? '',
  );

  final int id;
  final String phone;
  final bool isMain;
  final String comment;

  PhoneNumber toEntity()=>PhoneNumber(
    id: id, 
    phone: phone, 
    isMain: isMain, 
    comment: comment
  );
}