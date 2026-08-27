import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/auth/registration/data/models/organization_dto.dart';
import 'package:colloborator_v3/features/auth/registration/domain/entities/partner.dart';

final class PartnerDto {

  PartnerDto({required this.id,required this.title,required this.organizations,required this.territoryId});

  factory PartnerDto.fromJson(Map<String,dynamic> json)=>PartnerDto(
    id: json['id'] as int,
    title: json['name'] as String,
    territoryId: json['territory_id'] as int,
    organizations: JsonParser.list(json['organizations'], fromJson: OrganizationDto.fromJson),
  );

  final int id;
  final String title;
  final int territoryId;
  final List<OrganizationDto> organizations;

  Partner toEntity()=>Partner(
    id: id,
    title: title,
    territoryId: territoryId,
    organizations: organizations.map((dto) => dto.toEntity()).toList(),
  );
}