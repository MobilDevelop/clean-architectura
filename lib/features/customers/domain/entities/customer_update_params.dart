import 'package:colloborator_v3/features/customers/domain/entities/relative_kind.dart';
import 'package:equatable/equatable.dart';

/// Serverga yuboriladigan mijoz ma'lumoti. Tekshiruv `CustomerForm` da bo'lib
/// bo'lgan — bu yerga faqat to'liq ma'lumot yetib keladi.
final class CustomerUpdateParams extends Equatable {
  const CustomerUpdateParams({
    required this.customerId,
    required this.provinceId,
    required this.regionId,
    required this.villageId,
    required this.street,
    required this.houseNumber,
    required this.workplaceId,
    required this.mainPhone,
    required this.relativePhone,
    required this.relativeKind,
    required this.friendPhone,
    required this.flexData,
    required this.isEdit,
  });

  final int customerId;
  final int provinceId;
  final int regionId;
  final int villageId;
  final String street;
  final String houseNumber;
  final int workplaceId;

  /// Uchta raqam alohida maydon: backend ularni massivga yig'adi, bu esa
  /// yozilish shakli — DTO ning ishi.
  final String mainPhone;
  final String relativePhone;
  final RelativeKind relativeKind;
  final String friendPhone;

  /// Yuz tekshiruvidan kelgan ochilmaydigan ma'lumot. Bo'sh bo'lsa yuborilmaydi.
  final String flexData;

  /// Mavjud mijoz tahrirlanyaptimi yoki yangisi qo'shilyaptimi.
  final bool isEdit;

  @override
  List<Object?> get props => [
    customerId,
    provinceId,
    regionId,
    villageId,
    street,
    houseNumber,
    workplaceId,
    mainPhone,
    relativePhone,
    relativeKind,
    friendPhone,
    flexData,
    isEdit,
  ];
}
