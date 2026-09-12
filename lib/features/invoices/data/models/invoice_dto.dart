import 'package:colloborator_v3/core/contract/contract_status.dart';
import 'package:colloborator_v3/core/utils/json_value.dart';
import 'package:colloborator_v3/features/invoices/domain/entities/invoice.dart';

/// Ichma-ich obyektdan qiymat. Kalit yo'q yoki obyekt emas — `null`.
Object? _nested(Object? raw, String key) => raw is Map ? raw[key] : null;

/// `GET invoices` javobidagi bitta yozuv.
final class InvoiceDto {
  const InvoiceDto(this._json);

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(json);

  final Map<String, dynamic> _json;

  /// `status` va `partner` ichma-ich obyekt bo'lib keladi.
  ///
  /// Flex ularni `json['status']['id']` deb to'g'ridan-to'g'ri o'qiydi —
  /// `status` kelmasa butun ro'yxat parse paytida yiqilardi va ekran
  /// «Ma'lumot topilmadi» deb turib qolardi.
  Invoice toEntity() => Invoice(
    id: JsonValue.toInt(_json['id']),
    contractId: JsonValue.toInt(_json['contract_id']),
    partnerName: JsonValue.toText(_nested(_json['partner'], 'name')),
    // Summa so'mda keladi va bo'linmaydi (shartnomalar bilan bir xil qoida).
    price: JsonValue.toInt(_json['value']),
    status: ContractStatus.fromCode(JsonValue.toInt(_nested(_json['status'], 'id'))),
    waybillId: JsonValue.toInt(_json['waybill_id']),
    waybillUrl: JsonValue.toText(_json['waybill_url']),
  );
}
