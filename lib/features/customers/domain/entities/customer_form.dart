import 'package:colloborator_v3/features/customers/domain/entities/customer_info.dart';
import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';
import 'package:colloborator_v3/features/customers/domain/entities/phone_number.dart';
import 'package:colloborator_v3/features/customers/domain/entities/relative_kind.dart';
import 'package:colloborator_v3/features/customers/domain/entities/workplace_info.dart';
import 'package:equatable/equatable.dart';

enum CustomerFormIssue {
  none,
  provinceMissing,
  regionMissing,
  villageMissing,
  streetMissing,
  houseMissing,
  mainPhoneInvalid,
  relativePhoneInvalid,
  relativeKindMissing,
  friendPhoneInvalid,
  workplaceMissing,
}

/// Mijoz qo'shish formasi. Tanlanmagan maydon `null` — bo'sh obyekt emas:
/// `id == 0` bilan "tanlanmagan" ni bildirish shartnomani buzadi.
final class CustomerForm extends Equatable {
  const CustomerForm({
    required this.customerId,
    this.flexData = '',
    this.province,
    this.region,
    this.village,
    this.workplace,
    this.street = '',
    this.houseNumber = '',
    this.mainPhone = '',
    this.relativePhone = '',
    this.relativeKind,
    this.friendPhone = '',
  });

  /// Topilgan mijozning ma'lumoti bilan to'ldiradi — agent qaytadan yozmasin.
  factory CustomerForm.of(CustomerInfo info) {
    // Qarindosh raqami izohi bilan keladi, do'stniki izohsiz.
    final Iterable<PhoneNumber> extra = info.phones.where((PhoneNumber phone) => !phone.isMain);
    final PhoneNumber? relative = extra.where((PhoneNumber phone) => phone.comment.isNotEmpty).firstOrNull;
    final PhoneNumber? friend = extra.where((PhoneNumber phone) => phone.comment.isEmpty).firstOrNull;

    return CustomerForm(
      customerId: info.id,
      flexData: info.flexData,
      province: info.province.id == 0 ? null : info.province,
      region: info.region.id == 0 ? null : info.region,
      village: info.village.id == 0 ? null : info.village,
      workplace: info.workplace.id == 0 ? null : info.workplace,
      street: info.street,
      houseNumber: info.houseNumber,
      mainPhone: info.mainPhone?.phone ?? '',
      relativePhone: relative?.phone ?? '',
      relativeKind: RelativeKind.fromTitle(relative?.comment ?? ''),
      friendPhone: friend?.phone ?? '',
    );
  }

  final int customerId;

  /// Yuz tekshiruvidan kelgan va saqlashda qaytariladigan ma'lumot.
  final String flexData;

  final Province? province;
  final Region? region;
  final Village? village;
  final WorkplaceInfo? workplace;
  final String street;
  final String houseNumber;
  final String mainPhone;
  final String relativePhone;
  final RelativeKind? relativeKind;
  final String friendPhone;

  /// `+998 90 123-45-67` — 12 ta raqam.
  static const int phoneDigits = 12;

  static bool isPhoneComplete(String value) => value.replaceAll(RegExp(r'\D'), '').length == phoneDigits;

  CustomerFormIssue get issue {
    if (province == null) return CustomerFormIssue.provinceMissing;
    if (region == null) return CustomerFormIssue.regionMissing;
    if (village == null) return CustomerFormIssue.villageMissing;
    if (street.trim().isEmpty) return CustomerFormIssue.streetMissing;
    if (houseNumber.trim().isEmpty) return CustomerFormIssue.houseMissing;
    if (!isPhoneComplete(mainPhone)) return CustomerFormIssue.mainPhoneInvalid;
    if (!isPhoneComplete(relativePhone)) return CustomerFormIssue.relativePhoneInvalid;
    if (relativeKind == null) return CustomerFormIssue.relativeKindMissing;
    if (!isPhoneComplete(friendPhone)) return CustomerFormIssue.friendPhoneInvalid;
    if (workplace == null) return CustomerFormIssue.workplaceMissing;

    return CustomerFormIssue.none;
  }

  /// `issue` `none` bo'lganda hech qachon `null` qaytarmaydi. `null` — bizning
  /// nosozligimiz, chaqiruvchi uni ko'rinadigan xatoga aylantiradi.
  CustomerUpdateParams? toParams({required bool isEdit}) {
    final Province? province = this.province;
    final Region? region = this.region;
    final Village? village = this.village;
    final WorkplaceInfo? workplace = this.workplace;
    final RelativeKind? relativeKind = this.relativeKind;

    if (province == null || region == null || village == null || workplace == null || relativeKind == null) {
      return null;
    }

    return CustomerUpdateParams(
      customerId: customerId,
      provinceId: province.id,
      regionId: region.id,
      villageId: village.id,
      street: street.trim(),
      houseNumber: houseNumber.trim(),
      workplaceId: workplace.id,
      mainPhone: mainPhone,
      relativePhone: relativePhone,
      relativeKind: relativeKind,
      friendPhone: friendPhone,
      flexData: flexData,
      isEdit: isEdit,
    );
  }

  /// Viloyat o'zgarsa tuman va mahalla, tuman o'zgarsa mahalla va ish joyi
  /// bekor bo'ladi — ular ostki ro'yxatdan tanlangan.
  CustomerForm withProvince(Province value) =>
      copyWith(province: value, clearRegion: true, clearVillage: true, clearWorkplace: true);

  CustomerForm withRegion(Region value) => copyWith(region: value, clearVillage: true, clearWorkplace: true);

  CustomerForm copyWith({
    Province? province,
    Region? region,
    Village? village,
    WorkplaceInfo? workplace,
    String? street,
    String? houseNumber,
    String? mainPhone,
    String? relativePhone,
    RelativeKind? relativeKind,
    String? friendPhone,
    bool clearRegion = false,
    bool clearVillage = false,
    bool clearWorkplace = false,
  }) => CustomerForm(
    customerId: customerId,
    flexData: flexData,
    province: province ?? this.province,
    region: clearRegion ? null : region ?? this.region,
    village: clearVillage ? null : village ?? this.village,
    workplace: clearWorkplace ? null : workplace ?? this.workplace,
    street: street ?? this.street,
    houseNumber: houseNumber ?? this.houseNumber,
    mainPhone: mainPhone ?? this.mainPhone,
    relativePhone: relativePhone ?? this.relativePhone,
    relativeKind: relativeKind ?? this.relativeKind,
    friendPhone: friendPhone ?? this.friendPhone,
  );

  @override
  List<Object?> get props => [
    customerId,
    flexData,
    province,
    region,
    village,
    workplace,
    street,
    houseNumber,
    mainPhone,
    relativePhone,
    relativeKind,
    friendPhone,
  ];
}
