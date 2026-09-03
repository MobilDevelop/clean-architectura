import 'dart:convert';

import 'package:colloborator_v3/features/customers/domain/entities/customer_update_params.dart';

/// So'rov tanasi. Domain uchta raqamni alohida saqlaydi, backend esa massiv
/// kutadi — o'girish shu yerda (4.4).
final class CustomerUpdateDto {
  const CustomerUpdateDto(this._params);

  final CustomerUpdateParams _params;

  static String _digits(String phone) => '+${phone.replaceAll(RegExp(r'\D'), '')}';

  Map<String, dynamic> toJson() => <String, dynamic>{
    // Serverdan kelgani o'z holicha qaytariladi; bo'sh bo'lsa kalit yuborilmaydi.
    if (_params.flexData.isNotEmpty) 'flex_data': jsonDecode(_params.flexData),
    'id': _params.customerId,
    'province_id': _params.provinceId,
    'region_id': _params.regionId,
    'mfy_id': _params.villageId,
    'street': _params.street,
    'house_number': _params.houseNumber,
    'workplace_id': _params.workplaceId,
    // Flex bu kalitni har doim `true` yuborardi (yangi mijozda ham) va backend
    // faqat shu yo'lda sinalgan. Boshqa qiymat serverda sinalmagan tarmoq —
    // backend tasdiqlagunicha o'zgartirilmaydi.
    'is_edit': true,
    'phone_numbers': <Map<String, dynamic>>[
      <String, dynamic>{'phone_number': _digits(_params.mainPhone), 'is_main': true, 'comment': ''},
      <String, dynamic>{
        'phone_number': _digits(_params.relativePhone),
        'is_main': false,
        'comment': _params.relativeKind.title,
      },
      <String, dynamic>{'phone_number': _digits(_params.friendPhone), 'is_main': false, 'comment': ''},
    ],
  };
}
