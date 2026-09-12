import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/features/outputs/domain/entities/output_contract.dart';
import 'package:intl/intl.dart';

int _int(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

String _digits(Object? raw) => raw?.toString().replaceAll(RegExp(r'\D'), '') ?? '';

final DateFormat _day = DateFormat('dd.MM.yyyy');

/// `created_at` turli shaklda keladi (`2026-09-09T10:00:00Z`, `2026-09-09`).
/// O'qib bo'lmasa xom qiymat qoladi — sana ko'rsatish uchun istisno otish
/// mumkin emas.
String _date(Object? raw) {
  final String value = raw?.toString() ?? '';
  final DateTime? parsed = DateTime.tryParse(value);

  return parsed == null ? value : _day.format(parsed);
}

/// SMS yuborilgan payt.
///
/// `null` — sana yo'q yoki o'qilmadi; hisoblagich bunda chizilmaydi.
/// `toLocal()` majburiy: server `Z` bilan yuborsa `DateTime.tryParse` uni UTC
/// deb o'qiydi va ayirma qurilma mintaqasi qadar noto'g'ri chiqardi.
/// Mintaqasiz qator uchun bu amal hech nimani o'zgartirmaydi.
DateTime? _moment(Object? raw) {
  final DateTime? parsed = DateTime.tryParse(raw?.toString() ?? '');

  return parsed?.toLocal();
}

/// `GET output_contracts` javobidagi bitta yozuv.
final class OutputContractDto {
  const OutputContractDto(this._json);

  factory OutputContractDto.fromJson(Map<String, dynamic> json) => OutputContractDto(json);

  final Map<String, dynamic> _json;

  OutputContract toEntity() => OutputContract(
    id: _int(_json['id']),
    clientId: _int(_json['client_id']),
    clientName: _json['client_fullname']?.toString() ?? '',
    phone: _digits(_json['phone_number']),
    // Summa so'mda keladi va bo'linmaydi (KATM bilan bir xil qoida).
    totalPrice: _int(_json['total_price']),
    status: ContractStatus.fromCode(_int(_json['status_id'])),
    createdAt: _date(_json['created_at']),
    smsSentAt: _moment(_json['updated_at']),
  );
}

/// `GET get_products_for_cancelled/{id}` javobidagi bitta tovar.
final class OutputProductDto {
  const OutputProductDto(this._json);

  factory OutputProductDto.fromJson(Map<String, dynamic> json) => OutputProductDto(json);

  final Map<String, dynamic> _json;

  OutputProduct toEntity() => OutputProduct(
    id: _int(_json['id']),
    name: _json['name']?.toString() ?? '',
    category: _json['category']?.toString() ?? '',
    // Zaxira qiymat yo'q: kelmagan miqdorni `1` qilib ko'rsatish shartnoma
    // buzilishini qonuniy qiymatga aylantirardi (4.6). Nol dona ekranda
    // ko'rinadi va nosozlik shu bilan bilinadi.
    count: _int(_json['count']),
    price: _int(_json['price']),
  );
}
