import 'dart:convert';

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
    this.flexData,
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

  /// Server bergan va o'zgarishsiz qaytariladigan ma'lumot. Ilova uni ochmaydi.
  final Map<String,dynamic>? flexData;


  /// Ikkita endpoint bitta shaklni ikki xil kalit bilan yuboradi: ro'yxat
  /// (`client-search`) va yuz tekshiruvi (`check_client_by_myid`).
  factory CustomerInfoDto.fromJson(Map<String,dynamic> user)=>CustomerInfoDto(
    id: user['id'] as int,
    fullName: user['fio'] as String? ?? user['name'] as String? ?? '',
    inps: user['inps'] as String? ?? '',
    passportNumber: user['passport_series_number'] as String? ?? '',
    birthDay: user['date_of_birth'] as String? ?? user['birth_date'] as String? ?? '',
    mainAddress: user['main_address'] as String? ?? '',
    phones: JsonParser.list(user['phone_numbers'], fromJson: PhoneNumberDto.fromJson),
    passportGiven: user['passport_given_date'] as String? ?? user['passport_issue_date'] as String? ?? '',
    passportExpire: user['passport_expiry_date'] as String? ?? '',

    // Manzil va ish joyi — aynan shu ekranda to'ldiriladigan narsa, ya'ni yangi
    // mijozda ular hali yo'q. Majburiy deb kastlansa yuz tekshiruvidan o'tgan
    // mijoz formaga umuman yetib bormaydi.
    workplace: WorkplaceInfoDto.fromJson(user['workplace'] as Map<String,dynamic>? ?? const <String,dynamic>{}),
    province: ProvinceDto.fromJson(user['province'] as Map<String,dynamic>? ?? const <String,dynamic>{}),
    region: RegionDto.fromJson(user['region'] as Map<String,dynamic>? ?? const <String,dynamic>{}),
    village: VillageDto.fromJson(user['village'] as Map<String,dynamic>? ?? const <String,dynamic>{}),
    houseNumber: user['house_number'] as String? ?? '',
    street: user['street'] as String? ?? '',
    passportType: user['passport_type'] as bool? ?? false,
    flexData: user['flex_data'] as Map<String,dynamic>?,
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
    flexData: flexData == null ? '' : jsonEncode(flexData),
  );

}

final class ProvinceDto{
  const ProvinceDto({required this.id, required this.title});

  /// Bo'sh obyekt ham keladi — mijozda manzil hali tanlanmagan bo'lishi mumkin.
  /// `id: 0` shu holatni bildiradi.
  factory ProvinceDto.fromJson(Map<String,dynamic> json)=>ProvinceDto(
    id: json['id'] as int? ?? 0,
    title: json['name'] as String? ?? '',
  );

  final int id;
  final String title;

  Province toEntity()=>Province(id: id, title: title);

}

final class RegionDto{
  const RegionDto({required this.id, required this.title});

  /// Bo'sh obyekt ham keladi — mijozda manzil hali tanlanmagan bo'lishi mumkin.
  /// `id: 0` shu holatni bildiradi.
  factory RegionDto.fromJson(Map<String,dynamic> json)=>RegionDto(
    id: json['id'] as int? ?? 0,
    title: json['name'] as String? ?? '',
  );

  final int id;
  final String title;

  Region toEntity()=>Region(id: id, title: title);

}

final class VillageDto{
  const VillageDto({required this.id, required this.title});

  /// Bo'sh obyekt ham keladi — mijozda manzil hali tanlanmagan bo'lishi mumkin.
  /// `id: 0` shu holatni bildiradi.
  factory VillageDto.fromJson(Map<String,dynamic> json)=>VillageDto(
    id: json['id'] as int? ?? 0,
    title: json['name'] as String? ?? '',
  );

  final int id;
  final String title;

  Village toEntity()=>Village(id: id, title: title);

}