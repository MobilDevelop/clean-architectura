import 'package:colloborator_v3/core/utils/json_parser.dart';
import 'package:colloborator_v3/features/contract_create/domain/entities/contract_details.dart';

/// Ma'lumotnoma elementi hamma joyda bir xil shaklda keladi.
CatalogItem _catalogItem(Object? raw) {
  final Map<String, dynamic> json = raw is Map<String, dynamic> ? raw : const <String, dynamic>{};

  return CatalogItem(id: json['id'] as int? ?? 0, name: json['name'] as String? ?? '');
}

/// Narx va miqdor satr sifatida keladi (`"1800000"`). Butun so'mga o'giriladi;
/// kasr qismi bo'lsa tashlanadi — summalar so'mda hisoblanadi.
int _amount(Object? raw) => raw == null ? 0 : (num.tryParse(raw.toString()) ?? 0).toInt();

final class ContractProductDto {
  const ContractProductDto(this._json);

  factory ContractProductDto.fromJson(Map<String, dynamic> json) => ContractProductDto(json);

  final Map<String, dynamic> _json;

  ContractProduct toEntity() => ContractProduct(
    id: _json['id'] as int? ?? 0,
    supplier: _catalogItem(_json['partner']),
    category: _catalogItem(_json['category']),
    brand: _catalogItem(_json['brand']),
    variant: _catalogItem(_json['product_variant']),
    price: _amount(_json['price']),
    count: _amount(_json['count']),
    imeis: (_json['devices'] as List<dynamic>? ?? const <dynamic>[])
        .map((Object? e) => e?.toString() ?? '')
        .where((String e) => e.isNotEmpty)
        .toList(),
  );
}

final class ContractGuarantorDto {
  const ContractGuarantorDto(this._json);

  factory ContractGuarantorDto.fromJson(Map<String, dynamic> json) => ContractGuarantorDto(json);

  final Map<String, dynamic> _json;

  ContractGuarantor toEntity() => ContractGuarantor(
    clientId: _json['id'] as int? ?? 0,
    // Ro'yxat va yuz tekshiruvi ikki xil kalit yuboradi.
    fullName: _json['fio'] as String? ?? _json['name'] as String? ?? '',
    passport: _json['passport_series_number'] as String? ?? '',
  );
}

final class ContractDetailsDto {
  const ContractDetailsDto(this._json);

  factory ContractDetailsDto.fromJson(Map<String, dynamic> json) => ContractDetailsDto(json);

  final Map<String, dynamic> _json;

  Map<String, dynamic> _object(String key) {
    final Object? raw = _json[key];

    return raw is Map<String, dynamic> ? raw : const <String, dynamic>{};
  }

  ContractDetails toEntity() {
    final Map<String, dynamic> client = _object('client');
    final Map<String, dynamic> card = _object('plastic_card');
    final Map<String, dynamic> benefit = _object('benefit');

    // Flex bu kalitni `loans/{id}` da camelCase, alohida endpointda snake_case
    // deb o'qiydi. Qaysi biri to'g'ri ekani backenddan so'ralgan — ikkalasi ham
    // qabul qilinadi, aks holda biriktirilgan tarif jimgina yo'qoladi.
    final Object? tariffRaw = _json['specialTariff'] ?? _json['special_tariff'];
    final Map<String, dynamic> tariff = tariffRaw is Map<String, dynamic>
        ? tariffRaw
        : const <String, dynamic>{};

    return ContractDetails(
      id: _json['id'] as int? ?? 0,
      statusCode: _json['status_id'] as int? ?? 0,
      clientName: client['fio'] as String? ?? client['name'] as String? ?? '',
      termMonths: _json['term'] as int? ?? 0,
      paymentDay: _json['payment_day'] as int? ?? 0,
      isFormal: _json['formal'] as bool? ?? false,
      hasCarIncome: _json['checked_car_income'] as bool? ?? false,
      fileUrl: _json['file_url']?.toString() ?? '',
      products: JsonParser.list(
        _json['contract_products'],
        fromJson: ContractProductDto.fromJson,
      ).map((ContractProductDto dto) => dto.toEntity()).toList(),
      guarantors: JsonParser.list(
        _json['guarantors'],
        fromJson: ContractGuarantorDto.fromJson,
      ).map((ContractGuarantorDto dto) => dto.toEntity()).toList(),
      card: ContractCard(
        id: card['id'] as int? ?? 0,
        number: card['card_number'] as String? ?? '',
        phone: card['phone_number'] as String? ?? '',
        month: _amount(card['validity_month']),
        year: _amount(card['validity_year']),
      ),
      tariff: AppliedTariff(
        id: tariff['id'] as int? ?? 0,
        name: tariff['name']?.toString() ?? '',
        isActive: tariff['active'] as bool? ?? false,
      ),
      // Bonus yo'q bo'lsa `null` — nol summali bonus bilan bir xil emas.
      benefit: (_json['has_benefit'] as bool? ?? false)
          ? ContractBenefit(
              // `contract_id` aynan bonus obyektining ichida keladi va
              // `POST contract/benefit` shuni kutadi.
              contractId: benefit['contract_id'] as int? ?? 0,
              requiredAmount: _amount(benefit['required_amount']),
              availableAmount: _amount(benefit['available_amount']),
              usedAmount: _amount(benefit['used_amount']),
            )
          : null,
      mibFailReason: _json['mib_fail_reason'] as String? ?? '',
      katmFailReason: _json['katm_fail_reason'] as String? ?? '',
      workplaceCategoryId: client['workplace_category_id'] as int? ?? 0,
    );
  }
}
