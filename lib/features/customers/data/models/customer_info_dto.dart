import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/customers/data/models/phone_number_dto.dart';
import 'package:colloborator_v3/features/customers/data/models/workplace_info_dto.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';

final class CustomerInfoDto{

  const CustomerInfoDto({
    required this.id,
    required this.fullName,
    required this.inps,
    required this.passportNumber,
    required this.birthDay,
    required this.mainAddress,
    required this.phones,
    required this.passportGiven,
    required this.passportExpire,
    required this.workplace,
    required this.province,
    required this.region,
    required this.village,
    required this.houseNumber,
    required this.street,
    required this.passportType,
  });

  final int id;
  final String fullName;
  final String inps;
  final String passportNumber;
  final String birthDay;
  final String mainAddress;
  final List<PhoneNumberDto> phones;
  final String passportGiven;
  final String passportExpire;
  final WorkplaceInfoDto workplace;
  final ProvinceDto province;
  final RegionDto region;
  final VillageDto village;
  final String houseNumber;
  final String street;
  final bool passportType;


  factory CustomerInfoDto.fromJson(Map<String,dynamic> user)=>CustomerInfoDto(
    id: user['id'] as int, 
    fullName: user['fio'] as String, 
    inps: user['inps'] as String, 
    passportNumber: user['passport_series_number'] as String, 
    birthDay: user['birth_date'] as String, 
    mainAddress: user['main_address'] as String, 
    phones: JsonParser.list(user['phone_numbers'], fromJson: PhoneNumberDto.fromJson), 
    passportGiven: user['passport_issue_date'] as String, 
    passportExpire: user['passport_expiry_date'] as String, 
    workplace: WorkplaceInfoDto.fromJson(user['workplace'] as Map<String,dynamic>), 
    province: ProvinceDto.fromJson(user['province'] as Map<String,dynamic>),
    region: RegionDto.fromJson(user['region'] as Map<String,dynamic>),
    village: VillageDto.fromJson(user['village'] as Map<String,dynamic>), 
    houseNumber: user['house_number'] as String, 
    street: user['street'] as String, 
    passportType: user['passport_type'] as bool, 
  );

  CustomerInfo toEntity()=>CustomerInfo(
    id: id, 
    fullName: fullName, 
    inps: inps, 
    passportNumber: passportNumber, 
    birthDay: birthDay, 
    mainAddress: mainAddress, 
    phones: phones.map((phone) => phone.toEntity()).toList(), 
    passportGiven: passportGiven, 
    passportExpire: passportExpire, 
    workplace: workplace.toEntity(), 
    province: province.toEntity(), 
    region: region.toEntity(), 
    village: village.toEntity(), 
    houseNumber: houseNumber, 
    street: street, 
    passportType: passportType, 
  );

}

final class ProvinceDto{
  const ProvinceDto({required this.id, required this.title});

  factory ProvinceDto.fromJson(Map<String,dynamic> json)=>ProvinceDto(
    id: json['id'] as int, 
    title: json['name'] as String
  );

  final int id;
  final String title;

  Province toEntity()=>Province(id: id, title: title);

}

final class RegionDto{
  const RegionDto({required this.id, required this.title});

  factory RegionDto.fromJson(Map<String,dynamic> json)=>RegionDto(
    id: json['id'] as int, 
    title: json['name'] as String
  );

  final int id;
  final String title;

  Region toEntity()=>Region(id: id, title: title);

}

final class VillageDto{
  const VillageDto({required this.id, required this.title});

  factory VillageDto.fromJson(Map<String,dynamic> json)=>VillageDto(
    id: json['id'] as int, 
    title: json['name'] as String
  );

  final int id;
  final String title;

  Village toEntity()=>Village(id: id, title: title);

}