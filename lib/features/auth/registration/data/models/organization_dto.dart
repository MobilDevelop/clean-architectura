import 'package:colloborator_v3/features/auth/registration/domain/entities/organization.dart';

final class OrganizationDto {
  OrganizationDto({required this.id,required this.title});

  factory OrganizationDto.fromJson(Map<String,dynamic> json)=>OrganizationDto(
    id: json['id'] as int,
    title: json['name'] as String,
  );

  final int id;
  final String title;

  Organization toEntity()=>Organization(
    id: id,
    title: title,
  );
}