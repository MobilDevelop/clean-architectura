import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:equatable/equatable.dart';

final class CustomerInfo extends Equatable{

  const CustomerInfo({
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
    this.flexData = '',
  });

  final int id;
  final String fullName;
  final String inps;
  final String passportNumber;
  final String birthDay;
  final String mainAddress;
  final List<PhoneNumber> phones;
  final String passportGiven;
  final String passportExpire;
  final WorkplaceInfo workplace;
  final Province province;
  final Region region;
  final Village village;
  final String houseNumber;
  final String street;
  final bool passportType;

  /// Server bergan va o'zgarishsiz qaytarilishi kerak bo'lgan ma'lumot.
  /// Ilova uni ochmaydi, shuning uchun matn — `Map` entityda turmaydi (3.2).
  /// Bo'sh satr — bunday ma'lumot yo'q.
  final String flexData;

  PhoneNumber? get mainPhone {
  for (final phone in phones) {
    if (phone.isMain) return phone;
  }
  return null;
}

  @override
  List<Object?> get props => [id,fullName,inps,passportNumber,birthDay,mainAddress,phones,passportGiven,passportExpire,workplace,province,region,village,houseNumber,street,passportType,flexData];

}

final class Province extends Equatable{

  const Province({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id,title];
}

final class Region extends Equatable{

  const Region({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id,title];
}

final class Village extends Equatable{

  const Village({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id,title];
}